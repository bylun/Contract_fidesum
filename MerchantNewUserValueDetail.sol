pragma solidity ^0.4.25;
pragma experimental ABIEncoderV2;
import "./Table.sol";
import "./ConstantDef.sol";
import "./TableNameDef.sol";
import "./MerchantService.sol";

/*
    商户新开户奖分配明细
*/
contract MerchantNewUserValueDetail {
    
    ConstantDef constantDef;
    TableNameDef tableNameDef;
    MerchantService merchantService;
    TableFactory tableFactory;
    
    string table_name;
    
    event eventAddMerchantNewUserValueDetail(string status,string remark);
    
    // 初始化
    constructor() public {
        
        constantDef = new ConstantDef(); // 初始化通用合约
        tableNameDef = new TableNameDef();
        merchantService = new MerchantService();
        
        table_name = tableNameDef.constantMerchantNewUserValueDetail();
        
        tableFactory = TableFactory(0x1001); 
        tableFactory.createTable(table_name, "newUserValue_detail", "userId,trade_hash,merchantId,newUserValue,addTime");
    }
    
    
    /*
        函数描述：
            添加商户新开户奖分配明细
        参数： 
            userId 用户标识
            trade_hash 交易hash
            merchantId 商户标识标识
            newUserValue 新开户奖
        返回值：
            参数一： 
                 0 : 成功
                -1 : 商户不存在
                -2 : 其他异常
                -3 : 商户开户已超过90天
    */
    function addMerchantNewUserValueDetail(string userId,string trade_hash,string merchantId,uint newUserValue) public returns (int256) {
        int256 status;
        uint256 crtTime;
        (status,crtTime) = merchantService.getMerchantCrtTime(merchantId);
        if(status == 0){ // 商户存在判断
            emit eventAddMerchantNewUserValueDetail(constantDef.constant1002(),"error");
            return -1;
        }
        uint256 limitTime = crtTime + 90 days;
        if(limitTime < now) { // 商户开户90天判断
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
    	
        // 插入
        int256 ret_code = 0;
        int count = table.insert("newUserValue_detail", entry);
        
        if (count == 1) {
            // 成功
            ret_code = 0;
            emit eventAddMerchantNewUserValueDetail(constantDef.constantSuccess(),"success");
        } else {
            // 失败? 无权限或者其他错误
            ret_code = -2;
            emit eventAddMerchantNewUserValueDetail(constantDef.constantOtherError(),"error");
        }
        return ret_code;
    } 
    
    
    /*
        函数描述：
            查询指定商户的新开户奖明细
        参数： 
            merchantId 商户标识
        返回值：
            参数一： 
                userId 用户标识
                trade_hash 交易hash
                newUserValue_detail 商户应分配的新开户奖
                addTime 分配开户奖时间
    */
    function getMerchantNewUserValueDetail(string merchantId) public view returns(string[],string[],int256[],int256[]) {
        Table table = tableFactory.openTable(table_name);
        // 查询
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