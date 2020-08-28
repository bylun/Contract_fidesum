pragma solidity ^0.4.25;
pragma experimental ABIEncoderV2;
import "./Table.sol";
import "./ConstantDef.sol";
import "./TableNameDef.sol";
import "./StatisticService.sol";
import "./NodeBookkeeppingDetail.sol";

/*
    ���˽ڵ�����Լ
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
    
    
    // ��ʼ��
    constructor() public {
        constantDef = new ConstantDef(); // ��ʼ��ͨ�ú�Լ
        tableNameDef = new TableNameDef();
        statisticService = new StatisticService(); // ͳ�Ʒ����Լ
        nodeBookkeeppingDetail = new NodeBookkeeppingDetail();
        
        table_name = tableNameDef.constantNodeService();
        
        // node �ڵ�ͨ�ñ�ʶ
        // nodeId �ڵ�id
        // nodeNameShort �ڵ���
        // bookkeeping �ڵ���˷�
        // nodeHash �ڵ�����hash
        // flag ��ʶ 0����ͨ���˽ڵ㣬1��������˽ڵ�
        // status ״̬ 0 ������1 ������
        // time ���ʱ��
        tableFactory = TableFactory(0x1001); 
        tableFactory.createTable(table_name, "node", "nodeId,nodeNameShort,bookkeeping,nodeHash,flag,status,time");
    }
    
    /*
        ����������
            ����ڵ���˷�
        ����������
            nodeId ���˽ڵ��ʶ
            bookkepping_node ������Ľڵ���˷�
    */
    function addNodeBookkeppingUtil(string nodeId,uint bookkepping_node) private returns (int256){
        int256 ret = 0; 
        uint nodeBookkepping = 0;
        uint nodeBookkepping_manger = 0; // �ڵ����ۻ��ļ��˷��ܶ�
        uint nodeBookkepping_normal = 0; // �ڵ����ۻ��ļ��˷��ܶ�
        
        (ret, nodeBookkepping) = getBookkeepingValue(nodeId);
        if(ret == -1){
            emit eventAddNodeBookkepping(constantDef.constant1002(),"error");
            return -1;
        }
        nodeBookkepping += bookkepping_node; // �ۼӽڵ���˷�
        Table table = tableFactory.openTable(table_name);
        Entry entry = table.newEntry();
        entry.set("bookkeeping", nodeBookkepping);
        Condition condition = table.newCondition();
        condition.EQ("nodeId",nodeId);
            
        int count = table.update("node", entry, condition); // д��������
        if(count != 1) {
            // ʧ��? ��Ȩ�޻�����������?
            emit eventAddNodeBookkepping(constantDef.constantOtherError(),"error");
            return -5;
        }
        return 0;
    }
    
    /*
        ����������
            ����ڵ���˷ѣ������׽���0.05%���䵽�����ڵ��˻�
        ����������
            bookkepping_node_manager ����ڵ���˷�
            bookkepping_node_normal n-1�ڵ���˷�
    */
    function addNodeBookkepping(string userId,string trade_hash,uint bookkepping_node_manager,uint bookkepping_node_normal) public returns (int256){
        (string[] memory activeNodes,int256[] memory flags) = getActiveNodes();
        int256 ret = 0;     
        for(int256 i=0;i<int256(activeNodes.length);i++){
            string memory nodeId = activeNodes[uint256(i)];
            // n-1 ������ͨ�ڵ���˷�
            if(flags[uint256(i)] ==0){
                statisticService.setTotalNodeBookkeepping(bookkepping_node_normal); // ͳ��������Ľڵ���˷�
                ret = addNodeBookkeppingUtil(nodeId,bookkepping_node_normal);
                // ��¼������˷�
                nodeBookkeeppingDetail.addNodeBookkeeppingDetail(userId,trade_hash,nodeId,bookkepping_node_normal);
            }
            
            // �������ڵ���˷�
            if(flags[uint256(i)] ==1){
                statisticService.setTotalNodeBookkeepping(bookkepping_node_manager); // ͳ��������Ľڵ���˷�
                ret = addNodeBookkeppingUtil(nodeId,bookkepping_node_manager);
                // ��־ - ��¼������˷���ϸ
                nodeBookkeeppingDetail.addNodeBookkeeppingDetail(userId,trade_hash,nodeId,bookkepping_node_manager);
            }
        }
        if(ret == 0){
            emit eventAddNodeBookkepping(constantDef.constantSuccess(),"success");
        }
        return 0;
        
    }
    
        
    /*
        ����������
            ��ѯ�ڵ���˷�
        ������ 
            nodeId �ڵ�id
        ����ֵ��
            ����һ�� �ڵ���ڷ���1�������ڷ���-1
            �������� �ڵ����ʱ���ض�Ӧ�ڵ����ۻ��ļ��˷��ܶ�ڵ㲻����ʱ����0
    */
    function getBookkeepingValue(string nodeId) public view returns(int256,uint256) {
        Table table = tableFactory.openTable(table_name);
        // ��ѯ
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
        ����������
            �޸Ľڵ�״̬Ϊ������
        ������
            nodeId �ڵ�id
            nodeHash �ڵ�����hash
        ����ֵ��
            �޸Ľ��
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
        
        // ����ת���˻�
        int count = table.update("node", entry0, condition);
        if(count != 1) {
            // ʧ��? ��Ȩ�޻�����������?
            emit eventUpdateNodeStatus(constantDef.constantOtherError(),"error");
            return -5;
        }
        emit eventUpdateNodeStatus(constantDef.constantSuccess(),"success");
        return 0;
    }
    
    
    /*
        ����������
            �����˽ڵ�д��������
        ������ 
            nodeId �ڵ�id
            nodeNodeShort �ڵ����Ƽ��
            nodeHash �ڵ�����hash
            flag ���˽ڵ����� 0����ͨ���˽ڵ㣬1�����й������ʵļ��˽ڵ�
        ����ֵ��
            ����һ�� �ڵ���ڷ���0�������ڷ���-1
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
    	
        // ����
        int256 ret_code = 0;
        int count = table.insert("node", entry);
        if (count == 1) {
            // �ɹ�
            ret_code = 0;
            emit eventPutNode(constantDef.constantSuccess(),"success");
        } else {
            // ʧ��? ��Ȩ�޻�����������
            ret_code = -2;
            emit eventPutNode(constantDef.constantOtherError(),"error");
        }
        return ret_code;
    } 
    
    /*
        ����������
            ��ѯΨһ�ڵ�
        ������ 
            nodeId �ڵ��ʶ
            nodeHash �ڵ�����hash
        ����ֵ��
            0 �� �ڵ㲻���ڣ�
            1 �� �ڵ��Ѵ��ڣ�
    */
    function getNode(string nodeId,string nodeHash) public view returns(int256) {
        Table table = tableFactory.openTable(table_name);
        // ��ѯ
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
        ����������
            ��ѯ��Ч���˽ڵ�
        ������ 
            ��
        ����ֵ��
            ����һ�� ��Ч�ڵ��nodeId����
            �������� ���˽ڵ���������
    */
    function getActiveNodes() public view returns(string[],int256[]) {
        Table table = tableFactory.openTable(table_name);
        // ��ѯ
        Condition condition = table.newCondition();
        condition.EQ("status",int256(0)); // ��ڵ�״̬
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