pragma solidity ^0.4.25;
import "./Table.sol";
import "./ConstantDef.sol";
import "./StatisticService.sol";

/*
    通链服务合约
*/
contract BCManager {
    
    ConstantDef constantDef;
    TableFactory tableFactory;
    StatisticService statisticService;
    string constant TABLE_NAME_BLOCKCHAIN_MANAGER = "bcmanager_202008191640";
    
    event eventPutManager(string status,string remark);
    event eventUpdateManagerMaintainValue(string status,string remark);
    event eventUpdateManagerIniValue(string status,string remark);
    
    // 初始化
    constructor() public {
        
        constantDef = new ConstantDef(); // 初始化通用合约
        statisticService = new StatisticService(); // 初始化统计合约
        
        // managerId 管理方标识
        // managerNameShort 管理方简称
        // manager_init_value 管理方创始资产 
        // maintainValue 区块链维护费
        // managerHash 管理方属性hash
        // status 状态 0 正常；1 不可用
        // addTime 添加时间
        tableFactory = TableFactory(0x1001); 
        tableFactory.createTable(TABLE_NAME_BLOCKCHAIN_MANAGER, "manager", "managerId,managerNameShort,manager_init_value,maintainValue,managerHash,status,addTime");
    }
    
    /*
        函数描述：
            管理方信息上链
        参数： 
            merchantId 商户id
            merchantNameShort 商户简称
            merchantHash 商户属性hash
        返回值：
            参数一： 商户存在返回0，不存在返回-1
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
    	
        // 插入
        int256 ret_code = 0;
        int count = table.insert("manager", entry);
        if (count == 1) {
            // 成功
            ret_code = 0;
            emit eventPutManager(constantDef.constantSuccess(),"success");
        } else {
            // 失败? 无权限或者其他错误
            ret_code = -2;
            emit eventPutManager(constantDef.constantOtherError(),"error");
        }
        return ret_code;
    } 
    
    /*
        函数描述：
            查询区块链管理方信息
        参数： 
            mangerId 管理方标识
            mangerHash 管理方属性hash
        返回值：
            0 ： 管理方信息不存在；
            1 ： 管理方信息已存在；
    */
    function getManager(string managerId,string managerHash) public view returns(int256) {
        Table table = tableFactory.openTable(TABLE_NAME_BLOCKCHAIN_MANAGER);
        // 查询
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
        函数描述：
            查询创始价值
        参数： 
            无
        返回值：
            参数一： 管理方存在返回1，不存在返回-1
            参数二： 管理方存在时返回对应管理方所累积的记账费总额，管理方不存在时返回0
    */
    function getManagerInitValue() public view returns(uint256) {
        Table table = tableFactory.openTable(TABLE_NAME_BLOCKCHAIN_MANAGER);
        // 查询
        Condition condition = table.newCondition();
        condition.EQ("status",int256(0)); // 管理方状态，查询状态正常的管理方信息
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
        函数描述：
            更新创始价值
        参数：
            无
        返回值：
            修改结果
    */
    function updateManagerIniValue(uint iniValue) public returns (int256) {
        uint256 _per = getManagerInitValue();
        Table table = tableFactory.openTable(TABLE_NAME_BLOCKCHAIN_MANAGER);
        Entry entry0 = table.newEntry();
        entry0.set("manager_init_value", _per += iniValue*7); // 出去时除以7
        Condition condition = table.newCondition();
        condition.EQ("status",int256(0));
        // 更新转账账户
        int count = table.update("manager", entry0, condition);
        if(count != 1) {
            // 失败? 无权限或者其他错误?
            emit eventUpdateManagerIniValue(constantDef.constantOtherError(),"error");
            return -5;
        }
        // 累计总共所产生出的创始价值
        statisticService.setTotalInitValue(iniValue);
        emit eventUpdateManagerIniValue(constantDef.constantSuccess(),"success");
        return 0;
    }
    
    /*
        函数描述：
            查询区块链维护费
        参数： 
            无
        返回值：
            参数一： 管理方存在返回1，不存在返回-1
            参数二： 管理方存在时返回对应管理方所累积的区块链维护费，管理方不存在时返回0
    */
    function getManagerMaintainValue() public view returns(uint256) {
        Table table = tableFactory.openTable(TABLE_NAME_BLOCKCHAIN_MANAGER);
        // 查询
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
        函数描述：
            更新区块链维护费
        参数：
            maintainValue 单次交易所产生的区块链维护费
        返回值：
            修改结果
    */
    function updateManagerMaintainValue(uint maintainValue) public returns (int256) {
        uint256 _pre = getManagerMaintainValue();
        Table table = tableFactory.openTable(TABLE_NAME_BLOCKCHAIN_MANAGER);
        Entry entry0 = table.newEntry();
        entry0.set("maintainValue", _pre += maintainValue);
        Condition condition = table.newCondition();
        condition.EQ("status",int256(0));
        
        // 更新转账账户
        int count = table.update("manager", entry0, condition);
        if(count != 1) {
            // 失败? 无权限或者其他错误?
            emit eventUpdateManagerMaintainValue(constantDef.constantOtherError(),"error");
            return -5;
        }
        emit eventUpdateManagerMaintainValue(constantDef.constantSuccess(),"success");
        return 0;
    }
    
}


