pragma solidity ^0.4.25;
pragma experimental ABIEncoderV2;
import "./Table.sol";
import "./ConstantDef.sol";
import "./TableNameDef.sol";
import "./MerchantService.sol";

/*
    �̻��¿�����������ϸ
*/
contract MerchantNewUserValueDetail {
    
    ConstantDef constantDef;
    TableNameDef tableNameDef;
    MerchantService merchantService;
    TableFactory tableFactory;
    
    string table_name;
    
    event eventAddMerchantNewUserValueDetail(string status,string remark);
    
    // ��ʼ��
    constructor() public {
        
        constantDef = new ConstantDef(); // ��ʼ��ͨ�ú�Լ
        tableNameDef = new TableNameDef();
        merchantService = new MerchantService();
        
        table_name = tableNameDef.constantMerchantNewUserValueDetail();
        
        tableFactory = TableFactory(0x1001); 
        tableFactory.createTable(table_name, "newUserValue_detail", "userId,trade_hash,merchantId,newUserValue,addTime");
    }
    
    
    /*
        ����������
            ����̻��¿�����������ϸ
        ������ 
            userId �û���ʶ
            trade_hash ����hash
            merchantId �̻���ʶ��ʶ
            newUserValue �¿�����
        ����ֵ��
            ����һ�� 
                 0 : �ɹ�
                -1 : �̻�������
                -2 : �����쳣
                -3 : �̻������ѳ���90��
    */
    function addMerchantNewUserValueDetail(string userId,string trade_hash,string merchantId,uint newUserValue) public returns (int256) {
        int256 status;
        uint256 crtTime;
        (status,crtTime) = merchantService.getMerchantCrtTime(merchantId);
        if(status == 0){ // �̻������ж�
            emit eventAddMerchantNewUserValueDetail(constantDef.constant1002(),"error");
            return -1;
        }
        uint256 limitTime = crtTime + 90 days;
        if(limitTime < now) { // �̻�����90���ж�
            emit eventAddMerchantNewUserValueDetail(constantDef.constantOtherError(),"error");
            return -3;
        }
        
        Table table = tableFactory.openTable(table_name);
        Entry entry = table.newEntry();
        entry.set("userId", userId);
        entry.set("trade_hash", trade_hash);
        entry.set("merchantId", merchantId);
    	entry.set("newUserValue", newUserValue);
    	entry.set("addTime", uint256(now));
    	
        // ����
        int256 ret_code = 0;
        int count = table.insert("newUserValue_detail", entry);
        
        if (count == 1) {
            // �ɹ�
            ret_code = 0;
            emit eventAddMerchantNewUserValueDetail(constantDef.constantSuccess(),"success");
        } else {
            // ʧ��? ��Ȩ�޻�����������
            ret_code = -2;
            emit eventAddMerchantNewUserValueDetail(constantDef.constantOtherError(),"error");
        }
        return ret_code;
    } 
    
    
    /*
        ����������
            ��ѯָ���̻����¿�������ϸ
        ������ 
            merchantId �̻���ʶ
        ����ֵ��
            ����һ�� 
                userId �û���ʶ
                trade_hash ����hash
                newUserValue_detail �̻�Ӧ������¿�����
                addTime ���俪����ʱ��
    */
    function getMerchantNewUserValueDetail(string merchantId) public view returns(string[],string[],int256[],int256[]) {
        Table table = tableFactory.openTable(table_name);
        // ��ѯ
        Condition condition = table.newCondition();
        condition.EQ("merchantId",merchantId);
        Entries entries = table.select("newUserValue_detail", condition);
        string[] memory userIds = new string[](uint256(entries.size()));
        string[] memory trade_hashs = new string[](uint256(entries.size()));
        int256[] memory newUserValues = new int256[](uint256(entries.size()));
        int256[] memory addTimes = new int256[](uint256(entries.size()));
        
        for(int i=0; i<entries.size(); ++i) {
            Entry entry = entries.get(i);
            userIds[uint256(i)] = entry.getString("userId");
            trade_hashs[uint256(i)] = entry.getString("trade_hash");
            newUserValues[uint256(i)] = entry.getInt("newUserValue");
            addTimes[uint256(i)] = entry.getInt("addTime");
        }
        return (userIds,trade_hashs,newUserValues,addTimes);
    }
    
}