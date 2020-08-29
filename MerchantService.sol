pragma solidity ^0.4.25;
import "./Table.sol";
import "./ConstantDef.sol";
import "./TableNameDef.sol";

/*
    �̻������Լ
*/
contract MerchantService {

    ConstantDef constantDef;
    TableFactory tableFactory;
    TableNameDef tableNameDef;
    
    string table_name;
    
    event eventPutMerchant(string status,string remark);
    event eventUpdateMerchantNewUserValue(string status,string remark);
    
    // ��ʼ��
    constructor() public {
        
        constantDef = new ConstantDef(); // ��ʼ��ͨ�ú�Լ
        tableNameDef = new TableNameDef();
        table_name = tableNameDef.constantMerchantService();
        
        // merchant �̻�ͨ�ñ�ʶ
        // merchantId �̻�id
        // merchantNameShort �̻����
        // asset_value �̻��ʲ�
        // newUserValue �¿�����
        // merchantHash �̻�����hash
        // status ״̬ 0 ������1 ������
        // addTime ���ʱ��
        tableFactory = TableFactory(0x1001); 
        tableFactory.createTable(table_name, "merchant", "merchantId,merchantNameShort,asset_value,newUserValue,merchantHash,status,addTime");
    }
    
     /*
        ����������
            ���̻���Ϣд��������
        ������ 
            merchantId �̻�id
            merchantNameShort �̻����
            merchantHash �̻�����hash
        ����ֵ��
            ����һ�� �̻����ڷ���0�������ڷ���-1
    */
    function putMerchant(string merchantId,string merchantNameShort,string merchantHash) public returns (int256) {
        int256 res = getMerchant(merchantId,merchantHash);
        if(res == 1){
            emit eventPutMerchant(constantDef.constant1001(),"error");
            return -1;
        }
        
        Table table = tableFactory.openTable(table_name);
        Entry entry = table.newEntry();
        entry.set("merchantId", merchantId);
        entry.set("merchantNameShort",merchantNameShort);
    	entry.set("asset_value", int256(0));
    	entry.set("newUserValue", int256(0));
    	entry.set("merchantHash", merchantHash);
    	entry.set("status", int256(0));
    	entry.set("addTime", uint256(now));
    	
        // ����
        int256 ret_code = 0;
        int count = table.insert("merchant", entry);
        if (count == 1) {
            // �ɹ�
            ret_code = 0;
            emit eventPutMerchant(constantDef.constantSuccess(),"success");
        } else {
            // ʧ��? ��Ȩ�޻�����������
            ret_code = -2;
            emit eventPutMerchant(constantDef.constantOtherError(),"error");
        }
        return ret_code;
    } 
    
    /*
        ����������
            ��ѯ�̻��Ƿ����
        ������ 
            merchantId �ڵ��ʶ
            merchantHash �ڵ�����hash
        ����ֵ��
            0 �� �̻������ڣ�
            1 �� �̻��Ѵ��ڣ�
    */
    function getMerchant(string merchantId,string merchantHash) public view returns(int256) {
        Table table = tableFactory.openTable(table_name);
        // ��ѯ
        Condition condition = table.newCondition();
        condition.EQ("merchantId",merchantId);
        condition.EQ("merchantHash",merchantHash);
        Entries entries = table.select("merchant", condition);
        if (0 == uint256(entries.size())) {
            return 0;
        } else {
            return 1;
        }
    }
    
    /*
        ����������
            ��ѯ�̻��Ƿ����
        ������ 
            merchantId �ڵ��ʶ
        ����ֵ��
            0 �� �̻������ڣ�
            1 �� �̻��Ѵ��ڣ�
    */
    function getMerchant(string merchantId) public view returns(int256) {
        Table table = tableFactory.openTable(table_name);
        // ��ѯ
        Condition condition = table.newCondition();
        condition.EQ("merchantId",merchantId);
        Entries entries = table.select("merchant", condition);
        if (0 == uint256(entries.size())) {
            return 0;
        } else {
            return 1;
        }
    }
    
    /*
        ����������
            ��ѯ�̻��Ǽ�ʱ��
        ������ 
            merchantId �ڵ��ʶ
        ����ֵ��
            ����һ��0 �� �̻������ڣ�1 �� �̻��Ѵ��ڣ�
            ���������̻����ڷ��صǼ�ʱ�䣬�̻������ڷ���0
    */
    function getMerchantCrtTime(string merchantId) public view returns(int256,uint256) {
        int256 res = getMerchant(merchantId);
        if(res == 0){
            return (0,0);
        }
        Table table = tableFactory.openTable(table_name);
        // ��ѯ
        Condition condition = table.newCondition();
        condition.EQ("merchantId",merchantId);
        Entries entries = table.select("merchant", condition);
        Entry entry = entries.get(0);
        return (1,uint256(entry.getInt("addTime")));
    }
    
    /*
        ����������
            ��ѯ�̻��¿�����
        ������ 
            merchantId �̻���ʶ
        ����ֵ��
            0 �� �̻������ڣ�
            1 �� �̻��Ѵ��ڣ�
    */
    function getNewUserValue(string merchantId) public view returns(uint256) {
        Table table = tableFactory.openTable(table_name);
        // ��ѯ
        Condition condition = table.newCondition();
        condition.EQ("merchantId",merchantId);
        Entries entries = table.select("merchant", condition);
        Entry entry = entries.get(0);
        return uint256(entry.getInt("newUserValue"));
    }
    
    /*
        ����������
            �����̻����¿�����
        ������
            merchantId �̻���ʶ
            tonglianIniValue ���ʽ��׵�ͨ����ʼ��ֵ
        ����ֵ��
            �޸Ľ��
    */
    function updateMerchantNewUserValue(string merchantId,uint tonglianIniValue) public returns (int256) {
        uint256 _pre = getNewUserValue(merchantId);
        Table table = tableFactory.openTable(table_name);
        Entry entry0 = table.newEntry();
        entry0.set("newUserValue", _pre += tonglianIniValue);
        Condition condition = table.newCondition();
        condition.EQ("merchantId",merchantId);
        // ����ת���˻�
        int count = table.update("merchant", entry0, condition);
        if(count != 1) {
            // ʧ��? ��Ȩ�޻�����������?
            emit eventUpdateMerchantNewUserValue(constantDef.constantOtherError(),"error");
            return -5;
        }
        emit eventUpdateMerchantNewUserValue(constantDef.constantSuccess(),"success");
        return 0;
    }
    
        
}

