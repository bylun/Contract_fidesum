pragma solidity ^0.4.25;
pragma experimental ABIEncoderV2;
import "./Table.sol";
import "./ConstantDef.sol";
import "./TableNameDef.sol";
import "./StatisticService.sol";
import "./NodeBookkeeppingDetail.sol";

/*
    记账节点服务合约
*/
contract NodeService {
    
    ConstantDef constantDef;
    TableNameDef tableNameDef;
    StatisticService statisticService;
    NodeBookkeeppingDetail nodeBookkeeppingDetail;
    TableFactory tableFactory;
    
    string table_name;
    
    event eventPutNode(string status,string remark);
    event eventUpdateNodeStatus(string status,string remark);
    event eventAddNodeBookkepping(string status,string remark);
    
    
    // 初始化
    constructor() public {
        constantDef = new ConstantDef(); // 初始化通用合约
        tableNameDef = new TableNameDef();
        statisticService = new StatisticService(); // 统计服务合约
        nodeBookkeeppingDetail = new NodeBookkeeppingDetail();
        
        table_name = tableNameDef.constantNodeService();
        
        // node 节点通用标识
        // nodeId 节点id
        // nodeNameShort 节点简称
        // bookkeeping 节点记账费
        // nodeHash 节点属性hash
        // flag 标识 0：普通记账节点，1：管理记账节点
        // status 状态 0 正常；1 不可用
        // time 添加时间
        tableFactory = TableFactory(0x1001); 
        tableFactory.createTable(table_name, "node", "nodeId,nodeNameShort,bookkeeping,nodeHash,flag,status,time");
    }
    
    /*
        函数描述：
            分配节点记账费
        参数描述：
            nodeId 记账节点标识
            bookkepping_node 待分配的节点记账费
    */
    function addNodeBookkeppingUtil(string nodeId,uint bookkepping_node) private returns (int256){
        int256 ret = 0; 
        uint nodeBookkepping = 0;
        uint nodeBookkepping_manger = 0; // 节点所累积的记账费总额
        uint nodeBookkepping_normal = 0; // 节点所累积的记账费总额
        
        (ret, nodeBookkepping) = getBookkeepingValue(nodeId);
        if(ret == -1){
            emit eventAddNodeBookkepping(constantDef.constant1002(),"error");
            return -1;
        }
        nodeBookkepping += bookkepping_node; // 累加节点记账费
        Table table = tableFactory.openTable(table_name);
        Entry entry = table.newEntry();
        entry.set("bookkeeping", nodeBookkepping);
        Condition condition = table.newCondition();
        condition.EQ("nodeId",nodeId);
            
        int count = table.update("node", entry, condition); // 写入区块链
        if(count != 1) {
            // 失败? 无权限或者其他错误?
            emit eventAddNodeBookkepping(constantDef.constantOtherError(),"error");
            return -5;
        }
        return 0;
    }
    
    /*
        函数描述：
            分配节点记账费，按交易金额的0.05%分配到各个节点账户
        参数描述：
            bookkepping_node_manager 管理节点记账费
            bookkepping_node_normal n-1节点记账费
    */
    function addNodeBookkepping(string userId,string trade_hash,uint bookkepping_node_manager,uint bookkepping_node_normal) public returns (int256){
        (string[] memory activeNodes,int256[] memory flags) = getActiveNodes();
        int256 ret = 0;     
        for(int256 i=0;i<int256(activeNodes.length);i++){
            string memory nodeId = activeNodes[uint256(i)];
            // n-1 分配普通节点记账费
            if(flags[uint256(i)] ==0){
                statisticService.setTotalNodeBookkeepping(bookkepping_node_normal); // 统计所分配的节点记账费
                ret = addNodeBookkeppingUtil(nodeId,bookkepping_node_normal);
                // 记录分配记账费
                nodeBookkeeppingDetail.addNodeBookkeeppingDetail(userId,trade_hash,nodeId,bookkepping_node_normal);
            }
            
            // 分配管理节点记账费
            if(flags[uint256(i)] ==1){
                statisticService.setTotalNodeBookkeepping(bookkepping_node_manager); // 统计所分配的节点记账费
                ret = addNodeBookkeppingUtil(nodeId,bookkepping_node_manager);
                // 日志 - 记录分配记账费明细
                nodeBookkeeppingDetail.addNodeBookkeeppingDetail(userId,trade_hash,nodeId,bookkepping_node_manager);
            }
        }
        if(ret == 0){
            emit eventAddNodeBookkepping(constantDef.constantSuccess(),"success");
        }
        return 0;
        
    }
    
        
    /*
        函数描述：
            查询节点记账费
        参数： 
            nodeId 节点id
        返回值：
            参数一： 节点存在返回1，不存在返回-1
            参数二： 节点存在时返回对应节点所累积的记账费总额，节点不存在时返回0
    */
    function getBookkeepingValue(string nodeId) public view returns(int256,uint256) {
        Table table = tableFactory.openTable(table_name);
        // 查询
        Condition condition = table.newCondition();
        condition.EQ("nodeId",nodeId);
        Entries entries = table.select("node", condition);
        uint256 bookkepping_value = 0;
        if (0 == uint256(entries.size())) {
            return (-1, bookkepping_value);
        } else {
            Entry entry = entries.get(0);
            return (1, uint256(entry.getInt("bookkeeping")));
        }
    }
    
    
    /*
        函数描述：
            修改节点状态为不可用
        参数：
            nodeId 节点id
            nodeHash 节点属性hash
        返回值：
            修改结果
    */
    function updateNodeStats(string nodeId,string nodeHash) public returns (int256) {
        int256 res = getNode(nodeId,nodeHash);
        if(res == 0){
            emit eventUpdateNodeStatus(constantDef.constant1002(),"error");
            return -1;
        }
        Table table = tableFactory.openTable(table_name);

        Entry entry0 = table.newEntry();
        entry0.set("status", int256(1));
        
        Condition condition = table.newCondition();
        condition.EQ("nodeId",nodeId);
        condition.EQ("nodeHash",nodeHash);
        
        // 更新转账账户
        int count = table.update("node", entry0, condition);
        if(count != 1) {
            // 失败? 无权限或者其他错误?
            emit eventUpdateNodeStatus(constantDef.constantOtherError(),"error");
            return -5;
        }
        emit eventUpdateNodeStatus(constantDef.constantSuccess(),"success");
        return 0;
    }
    
    
    /*
        函数描述：
            将记账节点写入区块链
        参数： 
            nodeId 节点id
            nodeNodeShort 节点名称简称
            nodeHash 节点属性hash
            flag 记账节点类型 0：普通记账节点，1：具有管理性质的记账节点
        返回值：
            参数一： 节点存在返回0，不存在返回-1
    */
    function putNode(string nodeId,string nodeNameShort,string nodeHash,int256 flag) public returns (int256) {
        int256 res = getNode(nodeId,nodeHash);
        if(res == 1){
            emit eventPutNode(constantDef.constant1001(),"error");
            return -1;
        }
        
        Table table = tableFactory.openTable(table_name);
        Entry entry = table.newEntry();
        entry.set("node", "node");
        entry.set("nodeId", nodeId);
        entry.set("nodeNameShort",nodeNameShort);
    	entry.set("bookkeeping", int256(0));
    	entry.set("nodeHash", nodeHash);
    	entry.set("flag",flag);
    	entry.set("status", int256(0));
    	entry.set("time", int256(now));
    	
        // 插入
        int256 ret_code = 0;
        int count = table.insert("node", entry);
        if (count == 1) {
            // 成功
            ret_code = 0;
            emit eventPutNode(constantDef.constantSuccess(),"success");
        } else {
            // 失败? 无权限或者其他错误
            ret_code = -2;
            emit eventPutNode(constantDef.constantOtherError(),"error");
        }
        return ret_code;
    } 
    
    /*
        函数描述：
            查询唯一节点
        参数： 
            nodeId 节点标识
            nodeHash 节点属性hash
        返回值：
            0 ： 节点不存在；
            1 ： 节点已存在；
    */
    function getNode(string nodeId,string nodeHash) public view returns(int256) {
        Table table = tableFactory.openTable(table_name);
        // 查询
        Condition condition = table.newCondition();
        condition.EQ("nodeId",nodeId);
        condition.EQ("nodeHash",nodeHash);
        Entries entries = table.select("node", condition);
        if (0 == uint256(entries.size())) {
            return 0;
        } else {
            return 1;
        }
    }
    
    
    /*
        函数描述：
            查询有效记账节点
        参数： 
            无
        返回值：
            参数一： 有效节点的nodeId数组
            参数二： 记账节点类型数组
    */
    function getActiveNodes() public view returns(string[],int256[]) {
        Table table = tableFactory.openTable(table_name);
        // 查询
        Condition condition = table.newCondition();
        condition.EQ("status",int256(0)); // 活动节点状态
        Entries entries = table.select("node", condition);
        string[] memory nodeIds = new string[](uint256(entries.size()));
        int256[] memory flags = new int256[](uint256(entries.size()));
        for(int i=0; i<entries.size(); ++i) {
            Entry entry = entries.get(i);
            nodeIds[uint256(i)] = entry.getString("nodeId");
            flags[uint256(i)] = entry.getInt("flag");
        }
        return (nodeIds,flags);
    }
    
    
    
}