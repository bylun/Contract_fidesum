pragma solidity ^0.4.25;
import "./Table.sol";
import "./ConstantDef.sol";
import "./TableNameDef.sol";

/*
    商户服务合约
*/
contract MerchantService {

    ConstantDef constantDef;
    TableFactory tableFactory;
    TableNameDef tableNameDef;
    
    string table_name;
    
    event eventPutMerchant(string status,string remark);
    event eventUpdateMerchantNewUserValue(string status,string remark);
    
    // 初始化
    constructor() public {
        
        constantDef = new ConstantDef(); // 初始化通用合约
        tableNameDef = new TableNameDef();
        table_name = tableNameDef.constantMerchantService();
        
        // merchant 商户通用标识
        // merchantId 商户id
        // merchantNameShort 商户简称
        // asset_value 商户资产
        // newUserValue 新开户奖
        // merchantHash 商户属性hash
        // status 状态 0 正常；1 不可用
        // addTime 添加时间
        tableFactory = TableFactory(0x1001); 
        tableFactory.createTable(table_name, "merchant", "merchantId,merchantNameShort,asset_value,newUserValue,merchantHash,status,addTime");
    }
    
     /*
        函数描述：
            将商户信息写入区块链
        参数： 
            merchantId 商户id
            merchantNameShort 商户简称
            merchantHash 商户属性hash
        返回值：
            参数一： 商户存在返回0，不存在返回-1
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
    	
        // 插入
        int256 ret_code = 0;
        int count = table.insert("merchant", entry);
        if (count == 1) {
            // 成功
            ret_code = 0;
            emit eventPutMerchant(constantDef.constantSuccess(),"success");
        } else {
            // 失败? 无权限或者其他错误
            ret_code = -2;
            emit eventPutMerchant(constantDef.constantOtherError(),"error");
        }
        return ret_code;
    } 
    
    /*
        函数描述：
            查询商户是否存在
        参数： 
            merchantId 节点标识
            merchantHash 节点属性hash
        返回值：
            0 ： 商户不存在；
            1 ： 商户已存在；
    */
    function getMerchant(string merchantId,string merchantHash) public view returns(int256) {
        Table table = tableFactory.openTable(table_name);
        // 查询
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
        函数描述：
            查询商户是否存在
        参数： 
            merchantId 节点标识
        返回值：
            0 ： 商户不存在；
            1 ： 商户已存在；
    */
    function getMerchant(string merchantId) public view returns(int256) {
        Table table = tableFactory.openTable(table_name);
        // 查询
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
        函数描述：
            查询商户登记时间
        参数： 
            merchantId 节点标识
        返回值：
            参数一：0 ： 商户不存在；1 ： 商户已存在；
            参数二：商户存在返回登记时间，商户不存在返回0
    */
    function getMerchantCrtTime(string merchantId) public view returns(int256,uint256) {
        int256 res = getMerchant(merchantId);
        if(res == 0){
            return (0,0);
        }
        Table table = tableFactory.openTable(table_name);
        // 查询
        Condition condition = table.newCondition();
        condition.EQ("merchantId",merchantId);
        Entries entries = table.select("merchant", condition);
        Entry entry = entries.get(0);
        return (1,uint256(entry.getInt("addTime")));
    }
    
    /*
        函数描述：
            查询商户新开户奖
        参数： 
            merchantId 商户标识
        返回值：
            0 ： 商户不存在；
            1 ： 商户已存在；
    */
    function getNewUserValue(string merchantId) public view returns(uint256) {
        Table table = tableFactory.openTable(table_name);
        // 查询
        Condition condition = table.newCondition();
        condition.EQ("merchantId",merchantId);
        Entries entries = table.select("merchant", condition);
        Entry entry = entries.get(0);
        return uint256(entry.getInt("newUserValue"));
    }
    
    /*
        函数描述：
            更新商户的新开户奖
        参数：
            merchantId 商户标识
            tonglianIniValue 单笔交易的通链创始价值
        返回值：
            修改结果
    */
    function updateMerchantNewUserValue(string merchantId,uint tonglianIniValue) public returns (int256) {
        uint256 _pre = getNewUserValue(merchantId);
        Table table = tableFactory.openTable(table_name);
        Entry entry0 = table.newEntry();
        entry0.set("newUserValue", _pre += tonglianIniValue);
        Condition condition = table.newCondition();
        condition.EQ("merchantId",merchantId);
        // 更新转账账户
        int count = table.update("merchant", entry0, condition);
        if(count != 1) {
            // 失败? 无权限或者其他错误?
            emit eventUpdateMerchantNewUserValue(constantDef.constantOtherError(),"error");
            return -5;
        }
        emit eventUpdateMerchantNewUserValue(constantDef.constantSuccess(),"success");
        return 0;
    }
    
        
}

