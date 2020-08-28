pragma solidity ^0.4.25;
import "./Table.sol";
import "./ConstantDef.sol";
import "./StatisticService.sol";

/*
    ͨ�������Լ
*/
contract BCManager {
    
    ConstantDef constantDef;
    TableFactory tableFactory;
    StatisticService statisticService;
    string constant TABLE_NAME_BLOCKCHAIN_MANAGER = "bcmanager_202008191640";
    
    event eventPutManager(string status,string remark);
    event eventUpdateManagerMaintainValue(string status,string remark);
    event eventUpdateManagerIniValue(string status,string remark);
    
    // ��ʼ��
    constructor() public {
        
        constantDef = new ConstantDef(); // ��ʼ��ͨ�ú�Լ
        statisticService = new StatisticService(); // ��ʼ��ͳ�ƺ�Լ
        
        // managerId ������ʶ
        // managerNameShort �������
        // manager_init_value ������ʼ�ʲ� 
        // maintainValue ������ά����
        // managerHash ��������hash
        // status ״̬ 0 ������1 ������
        // addTime ���ʱ��
        tableFactory = TableFactory(0x1001); 
        tableFactory.createTable(TABLE_NAME_BLOCKCHAIN_MANAGER, "manager", "managerId,managerNameShort,manager_init_value,maintainValue,managerHash,status,addTime");
    }
    
    /*
        ����������
            ������Ϣ����
        ������ 
            merchantId �̻�id
            merchantNameShort �̻����
            merchantHash �̻�����hash
        ����ֵ��
            ����һ�� �̻����ڷ���0�������ڷ���-1
    */
    function putManager(string managerId,string managerNameShort,string managerHash) public returns (int256) {
        int256 res = getManager(managerId,managerHash);
        if(res == 1){
            emit eventPutManager(constantDef.constant1001(),"error");
            return -1;
        }
        
        Table table = tableFactory.openTable(TABLE_NAME_BLOCKCHAIN_MANAGER);
        Entry entry = table.newEntry();
        entry.set("managerId", managerId);
        entry.set("managerNameShort",managerNameShort);
        entry.set("manager_init_value", int256(0));
    	entry.set("maintainValue", int256(0));
    	entry.set("managerHash", managerHash);
    	entry.set("status", int256(0));
    	entry.set("addTime", uint256(now));
    	
        // ����
        int256 ret_code = 0;
        int count = table.insert("manager", entry);
        if (count == 1) {
            // �ɹ�
            ret_code = 0;
            emit eventPutManager(constantDef.constantSuccess(),"success");
        } else {
            // ʧ��? ��Ȩ�޻�����������
            ret_code = -2;
            emit eventPutManager(constantDef.constantOtherError(),"error");
        }
        return ret_code;
    } 
    
    /*
        ����������
            ��ѯ������������Ϣ
        ������ 
            mangerId ������ʶ
            mangerHash ��������hash
        ����ֵ��
            0 �� ������Ϣ�����ڣ�
            1 �� ������Ϣ�Ѵ��ڣ�
    */
    function getManager(string managerId,string managerHash) public view returns(int256) {
        Table table = tableFactory.openTable(TABLE_NAME_BLOCKCHAIN_MANAGER);
        // ��ѯ
        Condition condition = table.newCondition();
        condition.EQ("managerId",managerId);
        condition.EQ("managerHash",managerHash);
        Entries entries = table.select("manager", condition);
        if (0 == uint256(entries.size())) {
            return 0;
        } else {
            return 1;
        }
    }
    
     /*
        ����������
            ��ѯ��ʼ��ֵ
        ������ 
            ��
        ����ֵ��
            ����һ�� �������ڷ���1�������ڷ���-1
            �������� ��������ʱ���ض�Ӧ�������ۻ��ļ��˷��ܶ����������ʱ����0
    */
    function getManagerInitValue() public view returns(uint256) {
        Table table = tableFactory.openTable(TABLE_NAME_BLOCKCHAIN_MANAGER);
        // ��ѯ
        Condition condition = table.newCondition();
        condition.EQ("status",int256(0)); // ����״̬����ѯ״̬�����Ĺ�����Ϣ
        Entries entries = table.select("manager", condition);
        uint256 manager_init_value = 0;
        if (0 == uint256(entries.size())) {
            return manager_init_value;
        } else {
            Entry entry = entries.get(0);
            return uint256(entry.getInt("manager_init_value"));
        }
    }
    
    /*
        ����������
            ���´�ʼ��ֵ
        ������
            ��
        ����ֵ��
            �޸Ľ��
    */
    function updateManagerIniValue(uint iniValue) public returns (int256) {
        uint256 _per = getManagerInitValue();
        Table table = tableFactory.openTable(TABLE_NAME_BLOCKCHAIN_MANAGER);
        Entry entry0 = table.newEntry();
        entry0.set("manager_init_value", _per += iniValue*7); // ��ȥʱ����7
        Condition condition = table.newCondition();
        condition.EQ("status",int256(0));
        // ����ת���˻�
        int count = table.update("manager", entry0, condition);
        if(count != 1) {
            // ʧ��? ��Ȩ�޻�����������?
            emit eventUpdateManagerIniValue(constantDef.constantOtherError(),"error");
            return -5;
        }
        // �ۼ��ܹ����������Ĵ�ʼ��ֵ
        statisticService.setTotalInitValue(iniValue);
        emit eventUpdateManagerIniValue(constantDef.constantSuccess(),"success");
        return 0;
    }
    
    /*
        ����������
            ��ѯ������ά����
        ������ 
            ��
        ����ֵ��
            ����һ�� �������ڷ���1�������ڷ���-1
            �������� ��������ʱ���ض�Ӧ�������ۻ���������ά���ѣ�����������ʱ����0
    */
    function getManagerMaintainValue() public view returns(uint256) {
        Table table = tableFactory.openTable(TABLE_NAME_BLOCKCHAIN_MANAGER);
        // ��ѯ
        Condition condition = table.newCondition();
        condition.EQ("status",int256(0)); 
        Entries entries = table.select("manager", condition);
        uint256 maintainValue = 0;
        if (0 == uint256(entries.size())) {
            return maintainValue;
        } else {
            Entry entry = entries.get(0);
            return uint256(entry.getInt("maintainValue"));
        }
    }
    
    /*
        ����������
            ����������ά����
        ������
            maintainValue ���ν�����������������ά����
        ����ֵ��
            �޸Ľ��
    */
    function updateManagerMaintainValue(uint maintainValue) public returns (int256) {
        uint256 _pre = getManagerMaintainValue();
        Table table = tableFactory.openTable(TABLE_NAME_BLOCKCHAIN_MANAGER);
        Entry entry0 = table.newEntry();
        entry0.set("maintainValue", _pre += maintainValue);
        Condition condition = table.newCondition();
        condition.EQ("status",int256(0));
        
        // ����ת���˻�
        int count = table.update("manager", entry0, condition);
        if(count != 1) {
            // ʧ��? ��Ȩ�޻�����������?
            emit eventUpdateManagerMaintainValue(constantDef.constantOtherError(),"error");
            return -5;
        }
        emit eventUpdateManagerMaintainValue(constantDef.constantSuccess(),"success");
        return 0;
    }
    
}


