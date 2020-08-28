pragma solidity ^0.4.25;
pragma experimental ABIEncoderV2;
import "./Table.sol";
import "./ConstantDef.sol";


// 记账费明细合约
contract NodeBookkeeppingDetail {
    
    ConstantDef constantDef;
    TableFactory tableFactory;
    string constant TABLE_NAME_NODE_BOOKKEPPINGDETAIL = "node_bookkepping_detail_202008191640";
    
    event eventAddNodeBookkeppingDetail(string status,string remark);
    
    // 初始化
    constructor() public {
        
        constantDef = new ConstantDef(); // 初始化通用合约
        
        tableFactory = TableFactory(0x1001); 
        tableFactory.createTable(TABLE_NAME_NODE_BOOKKEPPINGDETAIL, "node_bookkepping_detail", "userId,trade_hash,nodeId,bookkepping_node_per,addTime");
    }
    
    /*
        函数描述：
            记录记账费分配明细
        参数： 
            userId 用户标识
            trade_hash 交易hash
            nodeId 记账节点标识
            bookkepping_node_per 记账节点应分配的记账费
        返回值：
            参数一： 商户存在返回0，不存在返回-1
    */
    function addNodeBookkeeppingDetail(string userId,string trade_hash,string nodeId,uint bookkepping_node_per) public returns (int256) {
        Table table = tableFactory.openTable(TABLE_NAME_NODE_BOOKKEPPINGDETAIL);
        Entry entry = table.newEntry();
        entry.set("userId", userId);
        entry.set("trade_hash", trade_hash);
        entry.set("nodeId", nodeId);
    	entry.set("bookkepping_node_per", bookkepping_node_per);
    	entry.set("addTime", uint256(now));
    	
        // 插入
        int256 ret_code = 0;
        int count = table.insert("node_bookkepping_detail", entry);
        
        if (count == 1) {
            // 成功
            ret_code = 0;
            emit eventAddNodeBookkeppingDetail(constantDef.constantSuccess(),"success");
        } else {
            // 失败? 无权限或者其他错误
            ret_code = -2;
            emit eventAddNodeBookkeppingDetail(constantDef.constantOtherError(),"error");
        }
        return ret_code;
    } 
    
    /*
        函数描述：
            查询所有记账费明细
        参数： 
            无
        返回值：
            参数一： 
                userId 用户标识
                trade_hash 交易hash
                nodeId 记账节点标识
                bookkepping_node_per 记账节点应分配的记账费
                addTime 添加时间
    */
    function getNodeBookkeeppingDetail() public view returns(string[],string[],string[],int256[],int256[]) {
        Table table = tableFactory.openTable(TABLE_NAME_NODE_BOOKKEPPINGDETAIL);
        // 查询
        Condition condition = table.newCondition();
        Entries entries = table.select("node_bookkepping_detail", condition);
        string[] memory userIds = new string[](uint256(entries.size()));
        string[] memory trade_hashs = new string[](uint256(entries.size()));
        string[] memory nodeIds = new string[](uint256(entries.size()));
        int256[] memory bookkepping_node_pers = new int256[](uint256(entries.size()));
        int256[] memory addTimes = new int256[](uint256(entries.size()));
        
        for(int i=0; i<entries.size(); ++i) {
            Entry entry = entries.get(i);
            userIds[uint256(i)] = entry.getString("userId");
            trade_hashs[uint256(i)] = entry.getString("trade_hash");
            nodeIds[uint256(i)] = entry.getString("nodeId");
            bookkepping_node_pers[uint256(i)] = entry.getInt("bookkepping_node_per");
            addTimes[uint256(i)] = entry.getInt("addTime");
        }
        return (userIds,trade_hashs,nodeIds,bookkepping_node_pers,addTimes);
    }
    
    
    
    
    
}