pragma solidity ^0.4.25;

import "./Table.sol";
import "./ConstantDef.sol";
import "./TableNameDef.sol";
import "./StatisticService.sol";

contract BCUser {
    
    ConstantDef constantDef;
    TableNameDef tableNameDef;
    StatisticService statisticService;
    
    string table_name;
    string public constant asset_name = "ERC20 Token -> TongBei";
    string public constant asset_symbol = "TB";
    
    event eventForRegisterUser(string status,string remark);
    event eventForProduceAssetsValue(string status,string remark);
    event eventForTransfer(int256 ret,string from_account,string to_account,uint256 asset_value);
    
    TableFactory tableFactory;
    
    constructor() public {
        constantDef = new ConstantDef();
        tableNameDef = new TableNameDef();
        statisticService = new StatisticService();
        table_name = tableNameDef.constantBCUser();
        tableFactory = TableFactory(0x1001); 
        tableFactory.createTable(table_name, "bcuser", "userId,asset_value,userHash,addTime");
    }
    
    /*
    	���� : ע���˻�
    	���� �� 
            userId : �û�id
            userHash  : �û�����HASH
    	����ֵ��
             0  ע��ɹ�
            -1 �ʲ��˻��Ѵ���
            -2 ��������
    */
    function register(string userId, string userHash) public returns(int256){
        // 1���ж��˻��Ƿ��Ѿ�����
        int256 res = isExistUser(userId);
        if(res == 1){
            emit eventForRegisterUser(constantDef.constant1001(),"error");
            return -1;
        }
        
        // 2����������
        int256 ret_code = 0;
        Table table = tableFactory.openTable(table_name);
        Entry entry = table.newEntry();
        entry.set("userId", userId);
        entry.set("userHash", userHash);
    	entry.set("asset_value", int256(0));
    	entry.set("addTime",uint256(now));
    	
        // ����
        int count = table.insert("bcuser", entry);
        if (count == 1) {
            // �ɹ�
            emit eventForRegisterUser(constantDef.constantSuccess(),"success");
            statisticService.setTotalUser(); // ͳ��ע���û�����
            ret_code = 0;
        } else {
            // ʧ��? ��Ȩ�޻�����������
            emit eventForRegisterUser(constantDef.constantOtherError(),"success");
            ret_code = -2;
        }
        return ret_code;
    }
    
    
    /*
    	���� : �����ʲ��˻���ѯ�ʲ����
    	���� : 
            userId : �ʲ��˻�

    	����ֵ��
            	����һ�� �ɹ�����0, �˻������ڷ���-1
            	�������� ��һ������Ϊ0ʱ��Ч���ʲ����
    */
    function getAssetsValue(string userId) public constant returns(int256, uint256) {
        uint256 asset_value = 0;
        // 1���ж��û��Ƿ����
        int256 res = isExistUser(userId);
        if(res == 0){
            return (-1, asset_value);
        }
        // 2����ѯ�û��ʲ�
        Table table = tableFactory.openTable(table_name);
        // ��ѯ
        Condition condition = table.newCondition();
        condition.EQ("userId",userId);
        Entries entries = table.select("bcuser", condition);
        if (0 == uint256(entries.size())) {
            return (-1, asset_value);
        } else {
            Entry entry = entries.get(0);
            asset_value = uint256(entry.getInt("asset_value"));
            return (0,asset_value);
        }
    }
    
    /*
    	���� : �ж��û��Ƿ���ڣ�BSN֧���¼�����ʹ�ã�
    	���� : 
            userId : �û���ʶ
    	����ֵ��
            �û����ڷ���1�������ڷ���0	
    */
    function isExistUser(string userId) public constant returns(int256) {
        Table table = tableFactory.openTable(table_name);
        // ��ѯ
        Condition condition = table.newCondition();
        condition.EQ("userId",userId);
        Entries entries = table.select("bcuser", condition);
        if (0 == uint256(entries.size())) {
            return 0;
        } else {
            return 1;
        }
    }   

    /*
    	���� : �����ʲ��˻���ѯע���û�������hash
    	���� �� 
            userId : �û�id
    	����ֵ��
            	����һ�� �ɹ�����0, �˻������ڷ���-1
            	�������� ��һ������Ϊ0ʱ��Ч���û�����hash
    */
    function getUserHash(string userId) public constant returns(int256, string) {
        Table table = tableFactory.openTable(table_name);
        // ��ѯ
        Condition condition = table.newCondition();
        condition.EQ("userId",userId);
        Entries entries = table.select("bcuser",condition);
        if (0 == uint256(entries.size())) {
            return (-1, "");
        } else {
            Entry entry = entries.get(0);
            return (0, entry.getString("userHash"));
        }
    }
    
    /*
    	���� : �������ָ��û�
    	���� �� 
            userId : �û�id
            assetValue  : ���֣�������ҵ�λ�ֵȼ�
    	����ֵ��
             0  �ɹ�
            -1 �ʲ��˻�������
            -2 ��������
    */
    function produceAssetsValue(string userId,uint256 assetValue) public returns(int256) {
        int256 ret_code = 0;
        int256 chain_ret_code = 0;
        uint256 chain_ret_asset_value = 0;
        (chain_ret_code, chain_ret_asset_value) = getAssetsValue(userId);
        if(chain_ret_code == -1){
            ret_code = -1;
            emit eventForProduceAssetsValue(constantDef.constant1002(),"error");
            return ret_code; 
        }
        
        Table table = tableFactory.openTable(table_name);
        Entry entry = table.newEntry();
        // �ۼ��û������ʲ����û��˻����ʲ�ת���ֵͬ����ҵ�λ'��'
        entry.set("asset_value", (chain_ret_asset_value += assetValue));
        Condition condition = table.newCondition();
        condition.EQ("userId",userId);
        int count = table.update("bcuser", entry, condition);
        if (count == 1) {
            // �ɹ�
            emit eventForProduceAssetsValue(constantDef.constantSuccess(),"success");
            ret_code = 0;
            statisticService.setTotalProduceAssetsValue(assetValue); // ͳ����������Ϊ�û������Ļ�������
        } else {
            // ʧ��? ��Ȩ�޻�����������
            emit eventForProduceAssetsValue(constantDef.constantOtherError(),"success");
            ret_code = -2;
        }
        return ret_code;
    }
    
    /*
    	���� : �ʲ�ת��
    	���� : 
            from_account : ת���ʲ��˻�
            to_account : �����ʲ��˻�
            assetValue : ת�ƽ��
    	����ֵ��
             0 �ʲ�ת�Ƴɹ�
            -1 ת���ʲ��˻�������
            -2 �����ʲ��˻�������
            -3 ����
            -4 ������
            -5 ��������
    */
//    function transfer(string from_account, string to_account, uint256 assetValue) public returns(int256) {
//        // ��ѯת���ʲ��˻���Ϣ
//        int ret_code = 0;
//        int256 ret = 0;
//        uint256 from_asset_value = 0;
//        uint256 to_asset_value = 0;
//        
//        // ת���˻��Ƿ����?
//        (ret, from_asset_value) = getAssetsValue(from_account);
//        if(ret != 0) {
//            ret_code = -1;
//            // ת���˻�������1
//            emit eventForTransfer(ret_code,from_account,to_account,assetValue);
//            return ret_code;
//
//        }
//
//        // �����˻��Ƿ����?
//        (ret, to_asset_value) = getAssetsValue(to_account);
//        if(ret != 0) {
//            ret_code = -2;
//            // �����ʲ����˻�������
//            emit eventForTransfer(ret_code,from_account,to_account,assetValue);
//            return ret_code;
//        }
//
//        if(from_asset_value < assetValue) {
//            ret_code = -3;
//            // ת���ʲ����˻�����
//            emit eventForTransfer(ret_code,from_account,to_account,assetValue);
//            return ret_code;
//        } 
//
//        if (to_asset_value + assetValue < to_asset_value) {
//            ret_code = -4;
//            emit eventForTransfer(ret_code,from_account,to_account,assetValue);
//            // �����˻�������
//            return ret_code;
//        }
//
//        Table table = tableFactory.openTable(TABLE_NAME_BCUSER);
//
//        Entry entry0 = table.newEntry();
//        entry0.set("userId", from_account);
//        entry0.set("asset_value", int256(from_asset_value - assetValue));
//        // ����ת���˻�
//        int count = table.update(from_account, entry0, table.newCondition());
//        if(count != 1) {
//            ret_code = -5;
//            // ʧ��? ��Ȩ�޻�����������?
//            emit eventForTransfer(ret_code,from_account,to_account,assetValue);
//            return ret_code;
//        }
//
//        Entry entry1 = table.newEntry();
//        entry1.set("userId", to_account);
//        entry1.set("asset_value", int256(to_asset_value + assetValue));
//        // ���½����˻�
//        table.update(to_account, entry1, table.newCondition());
//        
//        emit eventForTransfer(ret_code,from_account,to_account,assetValue);
//        return ret_code;
//    }

}
