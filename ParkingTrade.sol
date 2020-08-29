pragma solidity ^0.4.25;
pragma experimental ABIEncoderV2;
import "./Table.sol";
import "./BCUser.sol"; 
import "./BCManager.sol";
import "./ConstantDef.sol";
import "./NodeService.sol";

contract ParkingTrade {
    
    BCUser bcuser;
    ConstantDef constantDef;
    TableFactory tableFactory;
    NodeService nodeService;
    
    string constant TABLE_NAME = "ParkingTrade_202008191640";
        
    event eventPutTrade(string status,string remark);
    
    constructor() public {
        bcuser = new BCUser();
        constantDef = new ConstantDef(); // ��ʼ��ͨ�ú�Լ
        nodeService = new NodeService();
        tableFactory = TableFactory(0x1001);
        tableFactory.createTable(TABLE_NAME, "trade","userId,amount,trade_hash,addTime");
    }

    /*
    	���� : ��ȡ�û�ͣ���ɷѼ�¼
    	���� : 
            userId : �û���ʶ
    	����ֵ��
            	����һ�� �û����ڷ���0, �����ڷ���-1
            	�������� �����û�ͣ���ɷѼ�¼���û�����ʱ�ò�����ֵ
    */
    function select(string userId) public view returns (int256, string[]) {
        string[] memory tradeHash_list;
        Table table = tableFactory.openTable(TABLE_NAME);
        Condition condition = table.newCondition();
        condition.EQ("userId", userId);
        Entries entries = table.select("trade", condition);
                
        if(uint256(entries.size()) == 0) {
            return (-1,tradeHash_list);
        }
        
        tradeHash_list = new string[](uint256(entries.size()));

        for (int256 i = 0; i < entries.size(); ++i) {
            Entry entry = entries.get(i);
            tradeHash_list[uint256(i)] = entry.getString("trade_hash");
        }

        return (0, tradeHash_list);
    }
    
    /*
    	���� : ��֤������Ϣ�Ƿ����
    	���� : 
            userId : �ʲ��˻�
            trade_hash : ����hashֵ
    	����ֵ��
            	����һ�� ���ڷ���1, �����ڷ���-1
    */
    function isExisted(string userId,string trade_hash) public view returns (int256) {
        Table table = tableFactory.openTable(TABLE_NAME);
        Condition condition = table.newCondition();
        condition.EQ("trade_hash", trade_hash);
        condition.EQ("userId", userId);
        Entries entries = table.select("trade", condition);
        if(uint256(entries.size()) == 0){
            return -1;
        }
        return 1;
    }    
    
    /*
    	���� : �����û��ɷѼ�¼
    	���� : 
    	    merchantId �̻���ʶ
            userId : �û���ʶ
            amount : ʵ�����
            trade_hash : �ɷѼ�¼��hashֵ
            bookkepping_per ��ǰ�·���Ľڵ���˷�
    	����ֵ��
            	����һ�� 
            	    -1 : �ɷѼ�¼�Ѵ��ڣ�
            	     1 �� �ɷѼ�¼����ɹ���
            	    -2 �������쳣
    */
    function insert(string merchantId,string userId,uint256 amount,string trade_hash,uint bookkepping_node_manager,uint bookkepping_node_normal) public returns (int256) {
        bool status;
        uint _value;
        if(isExisted(userId,trade_hash) == 1){
            emit eventPutTrade(constantDef.constant1001(),"error");
            return -1;
        }
        Table table = tableFactory.openTable(TABLE_NAME);
        Entry entry = table.newEntry();
        entry.set("userId", userId);
        entry.set("amount", amount);
        entry.set("trade_hash", trade_hash);
        entry.set("addTime", uint256(now));

        int256 count = table.insert("trade", entry);
        if (count == 1) {
            if(amount != 0){
                // �û���������
                bcuser.produceAssetsValue(userId,amount);
                // ����ڵ���˷�
                nodeService.addNodeBookkepping(userId,trade_hash,bookkepping_node_manager,bookkepping_node_normal); 
            }
            emit eventPutTrade(constantDef.constantSuccess(),"success");
            return 0;
        }else{
            emit eventPutTrade(constantDef.constantOtherError(),"error");
            return -2;
        }
    }
    
    
}
