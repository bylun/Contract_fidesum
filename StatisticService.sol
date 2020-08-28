pragma solidity ^0.4.25;
import "./Table.sol";
import "./ConstantDef.sol";
import "./TableNameDef.sol";

/*
    统计服务合约
*/
contract StatisticService {
    
    ConstantDef constantDef;
    TableFactory tableFactory;
    TableNameDef tableNameDef;
    string table_name;
    
    // 初始化
    constructor() public {
        
        constantDef = new ConstantDef(); // 初始化通用合约
        tableNameDef = new TableNameDef();
        
        table_name = tableNameDef.constantStatisticService();
        
        // total_user 用户总数
        // total_nodeBookkeepping 节点记账费总计
        // total_produceAssetsValue 用户创生量总计
        // total_initValue 通链创始价值总计
        // cl_01 预留1
        // cl_02 预留2
        // cl_03 预留3
        tableFactory = TableFactory(0x1001); 
        tableFactory.createTable(table_name, "statistic", "total_user,total_nodeBookkeepping,total_produceAssetsValue,total_initValue,cl_01,cl_02,cl_03");
        init(); // 初始化数据
    }
    
     /*
    	描述 : 初始化数据
    	参数 ： 
    	    无
    	返回值：
    	    无
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
        函数描述：
            查询用户统计
        参数： 
            无
        返回值：
            用户总数
    */
    function getTotalUser() public view returns(uint256) {
        Table table = tableFactory.openTable(table_name);
        // 查询
        Entries entries = table.select("statistic", table.newCondition());
        Entry entry = entries.get(0);
        return  uint256(entry.getInt("total_user"));
    }
    
    
    /*
    	描述 : 更新用户统计
    	参数 ： 
            num : 数
    	返回值：
             0  成功
            -2 其他错误
    */
    function setTotalUser() public returns(int256) {
        int256 ret_code = 0;
        Table table = tableFactory.openTable(table_name);
        Entry entry = table.newEntry();
        uint256 _per = getTotalUser();
        entry.set("total_user",  _per + 1);
        int count = table.update("statistic", entry, table.newCondition());
        if (count == 1) {
            ret_code = 0; // 成功
        } else {
            ret_code = -2;
        }
        return ret_code;
    }
    
    /*
        函数描述：
            查询节点记账费统计
        参数： 
            无
        返回值：
            节点记账费总计
    */
    function getTotalNodeBookkeepping() public view returns(uint256) {
        Table table = tableFactory.openTable(table_name);
        // 查询
        Entries entries = table.select("statistic", table.newCondition());
        Entry entry = entries.get(0);
        return  uint256(entry.getInt("total_nodeBookkeepping"));
    }
    
    /*
    	描述 : 更新节点记账费统计
    	参数 ： 
            nodeBookkeepping : 每次交易的所有节点记账费
    	返回值：
             0  成功
            -2 其他错误
    */
    function setTotalNodeBookkeepping(uint256 nodeBookkeepping) public returns(int256) {
        uint256 _per = getTotalNodeBookkeepping(); // 查询此前的节点记账费统计
        int256 ret_code = 0;
        Table table = tableFactory.openTable(table_name);
        Entry entry = table.newEntry();
        entry.set("total_nodeBookkeepping", _per += nodeBookkeepping );
        int count = table.update("statistic", entry, table.newCondition());
        if (count == 1) {
            ret_code = 0; // 成功
        } else {
            ret_code = -2;
        }
        return ret_code;
    }
    
    /*
        函数描述：
            查询用户创生资产统计
        参数： 
            无
        返回值：
            用户创生资产总计
    */
    function getTotalProduceAssetsValue() public view returns(uint256) {
        Table table = tableFactory.openTable(table_name);
        // 查询
        Entries entries = table.select("statistic", table.newCondition());
        Entry entry = entries.get(0);
        return  uint256(entry.getInt("total_produceAssetsValue"));
    }
    
    /*
    	描述 : 更新用户创生资产统计
    	参数 ： 
            produceAssetsValue : 用户单次交易创生的资产
    	返回值：
             0  成功
            -2 其他错误
    */
    function setTotalProduceAssetsValue(uint256 produceAssetsValue) public returns(int256) {
        uint256 _per = getTotalProduceAssetsValue(); // 查询此前的节点记账费统计
        int256 ret_code = 0;
        Table table = tableFactory.openTable(table_name);
        Entry entry = table.newEntry();
        entry.set("total_produceAssetsValue", _per += produceAssetsValue );
        int count = table.update("statistic", entry, table.newCondition());
        if (count == 1) {
            ret_code = 0; // 成功
        } else {
            ret_code = -2;
        }
        return ret_code;
    }
    
    /*
        函数描述：
            查询通链创始价值
        参数： 
            无
        返回值：
            通链总计创始价值
    */
    function getTotalInitValue() public view returns(uint256) {
        Table table = tableFactory.openTable(table_name);
        // 查询
        Entries entries = table.select("statistic", table.newCondition());
        Entry entry = entries.get(0);
        return  uint256(entry.getInt("total_initValue"));
    }
    
    /*
    	描述 : 更新通链创始价值统计
    	参数 ： 
            initValue : 单次交易所产生的通链创始价值（未分配前）
    	返回值：
             0  成功
            -2 其他错误
    */
    function setTotalInitValue(uint256 initValue) public returns(int256) {
        uint256 _per = getTotalInitValue(); // 查询此前的通链创始价值总计
        int256 ret_code = 0;
        Table table = tableFactory.openTable(table_name);
        Entry entry = table.newEntry();
        entry.set("total_initValue", _per += initValue );
        int count = table.update("statistic", entry, table.newCondition());
        if (count == 1) {
            ret_code = 0; // 成功
        } else {
            ret_code = -2;
        }
        return ret_code;
    }
    
    
    
}