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
    	描述 : 注册账户
    	参数 ： 
            userId : 用户id
            userHash  : 用户属性HASH
    	返回值：
             0  注册成功
            -1 资产账户已存在
            -2 其他错误
    */
    function register(string userId, string userHash) public returns(int256){
        // 1、判断账户是否已经存在
        int256 res = isExistUser(userId);
        if(res == 1){
            emit eventForRegisterUser(constantDef.constant1001(),"error");
            return -1;
        }
        
        // 2、增加数据
        int256 ret_code = 0;
        Table table = tableFactory.openTable(table_name);
        Entry entry = table.newEntry();
        entry.set("userId", userId);
        entry.set("userHash", userHash);
    	entry.set("asset_value", int256(0));
    	entry.set("addTime",uint256(now));
    	
        // 插入
        int count = table.insert("bcuser", entry);
        if (count == 1) {
            // 成功
            emit eventForRegisterUser(constantDef.constantSuccess(),"success");
            statisticService.setTotalUser(); // 统计注册用户总数
            ret_code = 0;
        } else {
            // 失败? 无权限或者其他错误
            emit eventForRegisterUser(constantDef.constantOtherError(),"success");
            ret_code = -2;
        }
        return ret_code;
    }
    
    
    /*
    	描述 : 根据资产账户查询资产金额
    	参数 : 
            userId : 资产账户

    	返回值：
            	参数一： 成功返回0, 账户不存在返回-1
            	参数二： 第一个参数为0时有效，资产金额
    */
    function getAssetsValue(string userId) public constant returns(int256, uint256) {
        uint256 asset_value = 0;
        // 1、判断用户是否存在
        int256 res = isExistUser(userId);
        if(res == 0){
            return (-1, asset_value);
        }
        // 2、查询用户资产
        Table table = tableFactory.openTable(table_name);
        // 查询
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
    	描述 : 判断用户是否存在（BSN支持事件后不再使用）
    	参数 : 
            userId : 用户标识
    	返回值：
            用户存在返回1，不存在返回0	
    */
    function isExistUser(string userId) public constant returns(int256) {
        Table table = tableFactory.openTable(table_name);
        // 查询
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
    	描述 : 根据资产账户查询注册用户的属性hash
    	参数 ： 
            userId : 用户id
    	返回值：
            	参数一： 成功返回0, 账户不存在返回-1
            	参数二： 第一个参数为0时有效，用户属性hash
    */
    function getUserHash(string userId) public constant returns(int256, string) {
        Table table = tableFactory.openTable(table_name);
        // 查询
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
    	描述 : 创生积分给用户
    	参数 ： 
            userId : 用户id
            assetValue  : 积分，和人民币单位分等价
    	返回值：
             0  成功
            -1 资产账户不存在
            -2 其他错误
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
        // 累计用户创生资产到用户账户，资产转入价值同人民币单位'分'
        entry.set("asset_value", (chain_ret_asset_value += assetValue));
        Condition condition = table.newCondition();
        condition.EQ("userId",userId);
        int count = table.update("bcuser", entry, condition);
        if (count == 1) {
            // 成功
            emit eventForProduceAssetsValue(constantDef.constantSuccess(),"success");
            ret_code = 0;
            statisticService.setTotalProduceAssetsValue(assetValue); // 统计区块链已为用户创生的积分总量
        } else {
            // 失败? 无权限或者其他错误
            emit eventForProduceAssetsValue(constantDef.constantOtherError(),"success");
            ret_code = -2;
        }
        return ret_code;
    }
    
    /*
    	描述 : 资产转移
    	参数 : 
            from_account : 转移资产账户
            to_account : 接收资产账户
            assetValue : 转移金额
    	返回值：
             0 资产转移成功
            -1 转移资产账户不存在
            -2 接收资产账户不存在
            -3 金额不足
            -4 金额溢出
            -5 其他错误
    */
//    function transfer(string from_account, string to_account, uint256 assetValue) public returns(int256) {
//        // 查询转移资产账户信息
//        int ret_code = 0;
//        int256 ret = 0;
//        uint256 from_asset_value = 0;
//        uint256 to_asset_value = 0;
//        
//        // 转移账户是否存在?
//        (ret, from_asset_value) = getAssetsValue(from_account);
//        if(ret != 0) {
//            ret_code = -1;
//            // 转移账户不存在1
//            emit eventForTransfer(ret_code,from_account,to_account,assetValue);
//            return ret_code;
//
//        }
//
//        // 接受账户是否存在?
//        (ret, to_asset_value) = getAssetsValue(to_account);
//        if(ret != 0) {
//            ret_code = -2;
//            // 接收资产的账户不存在
//            emit eventForTransfer(ret_code,from_account,to_account,assetValue);
//            return ret_code;
//        }
//
//        if(from_asset_value < assetValue) {
//            ret_code = -3;
//            // 转移资产的账户金额不足
//            emit eventForTransfer(ret_code,from_account,to_account,assetValue);
//            return ret_code;
//        } 
//
//        if (to_asset_value + assetValue < to_asset_value) {
//            ret_code = -4;
//            emit eventForTransfer(ret_code,from_account,to_account,assetValue);
//            // 接收账户金额溢出
//            return ret_code;
//        }
//
//        Table table = tableFactory.openTable(TABLE_NAME_BCUSER);
//
//        Entry entry0 = table.newEntry();
//        entry0.set("userId", from_account);
//        entry0.set("asset_value", int256(from_asset_value - assetValue));
//        // 更新转账账户
//        int count = table.update(from_account, entry0, table.newCondition());
//        if(count != 1) {
//            ret_code = -5;
//            // 失败? 无权限或者其他错误?
//            emit eventForTransfer(ret_code,from_account,to_account,assetValue);
//            return ret_code;
//        }
//
//        Entry entry1 = table.newEntry();
//        entry1.set("userId", to_account);
//        entry1.set("asset_value", int256(to_asset_value + assetValue));
//        // 更新接收账户
//        table.update(to_account, entry1, table.newCondition());
//        
//        emit eventForTransfer(ret_code,from_account,to_account,assetValue);
//        return ret_code;
//    }

}
