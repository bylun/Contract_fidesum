pragma solidity ^0.4.25;
import "./Table.sol";
import "./ConstantDef.sol";
import "./TableNameDef.sol";

/*
    ͳ�Ʒ����Լ
*/
contract StatisticService {
    
    ConstantDef constantDef;
    TableFactory tableFactory;
    TableNameDef tableNameDef;
    string table_name;
    
    // ��ʼ��
    constructor() public {
        
        constantDef = new ConstantDef(); // ��ʼ��ͨ�ú�Լ
        tableNameDef = new TableNameDef();
        
        table_name = tableNameDef.constantStatisticService();
        
        // total_user �û�����
        // total_nodeBookkeepping �ڵ���˷��ܼ�
        // total_produceAssetsValue �û��������ܼ�
        // total_initValue ͨ����ʼ��ֵ�ܼ�
        // cl_01 Ԥ��1
        // cl_02 Ԥ��2
        // cl_03 Ԥ��3
        tableFactory = TableFactory(0x1001); 
        tableFactory.createTable(table_name, "statistic", "total_user,total_nodeBookkeepping,total_produceAssetsValue,total_initValue,cl_01,cl_02,cl_03");
        init(); // ��ʼ������
    }
    
     /*
    	���� : ��ʼ������
    	���� �� 
    	    ��
    	����ֵ��
    	    ��
    */
    function init() private returns(int256) {
        Table table = tableFactory.openTable(table_name);
        Entry entry = table.newEntry();
        entry.set("total_user", uint256(0));
        entry.set("total_nodeBookkeepping", uint256(0));
    	entry.set("total_produceAssetsValue", uint256(0));
    	entry.set("total_initValue",uint256(0));
    	entry.set("cl_01",uint256(0));
    	entry.set("cl_02",uint256(0));
    	entry.set("cl_03",uint256(0));
        table.insert("statistic", entry);
    }
    
    /*
        ����������
            ��ѯ�û�ͳ��
        ������ 
            ��
        ����ֵ��
            �û�����
    */
    function getTotalUser() public view returns(uint256) {
        Table table = tableFactory.openTable(table_name);
        // ��ѯ
        Entries entries = table.select("statistic", table.newCondition());
        Entry entry = entries.get(0);
        return  uint256(entry.getInt("total_user"));
    }
    
    
    /*
    	���� : �����û�ͳ��
    	���� �� 
            num : ��
    	����ֵ��
             0  �ɹ�
            -2 ��������
    */
    function setTotalUser() public returns(int256) {
        int256 ret_code = 0;
        Table table = tableFactory.openTable(table_name);
        Entry entry = table.newEntry();
        uint256 _per = getTotalUser();
        entry.set("total_user",  _per + 1);
        int count = table.update("statistic", entry, table.newCondition());
        if (count == 1) {
            ret_code = 0; // �ɹ�
        } else {
            ret_code = -2;
        }
        return ret_code;
    }
    
    /*
        ����������
            ��ѯ�ڵ���˷�ͳ��
        ������ 
            ��
        ����ֵ��
            �ڵ���˷��ܼ�
    */
    function getTotalNodeBookkeepping() public view returns(uint256) {
        Table table = tableFactory.openTable(table_name);
        // ��ѯ
        Entries entries = table.select("statistic", table.newCondition());
        Entry entry = entries.get(0);
        return  uint256(entry.getInt("total_nodeBookkeepping"));
    }
    
    /*
    	���� : ���½ڵ���˷�ͳ��
    	���� �� 
            nodeBookkeepping : ÿ�ν��׵����нڵ���˷�
    	����ֵ��
             0  �ɹ�
            -2 ��������
    */
    function setTotalNodeBookkeepping(uint256 nodeBookkeepping) public returns(int256) {
        uint256 _per = getTotalNodeBookkeepping(); // ��ѯ��ǰ�Ľڵ���˷�ͳ��
        int256 ret_code = 0;
        Table table = tableFactory.openTable(table_name);
        Entry entry = table.newEntry();
        entry.set("total_nodeBookkeepping", _per += nodeBookkeepping );
        int count = table.update("statistic", entry, table.newCondition());
        if (count == 1) {
            ret_code = 0; // �ɹ�
        } else {
            ret_code = -2;
        }
        return ret_code;
    }
    
    /*
        ����������
            ��ѯ�û������ʲ�ͳ��
        ������ 
            ��
        ����ֵ��
            �û������ʲ��ܼ�
    */
    function getTotalProduceAssetsValue() public view returns(uint256) {
        Table table = tableFactory.openTable(table_name);
        // ��ѯ
        Entries entries = table.select("statistic", table.newCondition());
        Entry entry = entries.get(0);
        return  uint256(entry.getInt("total_produceAssetsValue"));
    }
    
    /*
    	���� : �����û������ʲ�ͳ��
    	���� �� 
            produceAssetsValue : �û����ν��״������ʲ�
    	����ֵ��
             0  �ɹ�
            -2 ��������
    */
    function setTotalProduceAssetsValue(uint256 produceAssetsValue) public returns(int256) {
        uint256 _per = getTotalProduceAssetsValue(); // ��ѯ��ǰ�Ľڵ���˷�ͳ��
        int256 ret_code = 0;
        Table table = tableFactory.openTable(table_name);
        Entry entry = table.newEntry();
        entry.set("total_produceAssetsValue", _per += produceAssetsValue );
        int count = table.update("statistic", entry, table.newCondition());
        if (count == 1) {
            ret_code = 0; // �ɹ�
        } else {
            ret_code = -2;
        }
        return ret_code;
    }
    
    /*
        ����������
            ��ѯͨ����ʼ��ֵ
        ������ 
            ��
        ����ֵ��
            ͨ���ܼƴ�ʼ��ֵ
    */
    function getTotalInitValue() public view returns(uint256) {
        Table table = tableFactory.openTable(table_name);
        // ��ѯ
        Entries entries = table.select("statistic", table.newCondition());
        Entry entry = entries.get(0);
        return  uint256(entry.getInt("total_initValue"));
    }
    
    /*
    	���� : ����ͨ����ʼ��ֵͳ��
    	���� �� 
            initValue : ���ν�����������ͨ����ʼ��ֵ��δ����ǰ��
    	����ֵ��
             0  �ɹ�
            -2 ��������
    */
    function setTotalInitValue(uint256 initValue) public returns(int256) {
        uint256 _per = getTotalInitValue(); // ��ѯ��ǰ��ͨ����ʼ��ֵ�ܼ�
        int256 ret_code = 0;
        Table table = tableFactory.openTable(table_name);
        Entry entry = table.newEntry();
        entry.set("total_initValue", _per += initValue );
        int count = table.update("statistic", entry, table.newCondition());
        if (count == 1) {
            ret_code = 0; // �ɹ�
        } else {
            ret_code = -2;
        }
        return ret_code;
    }
    
    
    
}