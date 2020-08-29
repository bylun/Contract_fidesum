pragma solidity ^0.4.25;
pragma experimental ABIEncoderV2;
import "./Table.sol";
import "./BCUser.sol"; 
import "./BCManager.sol";
import "./ConstantDef.sol";
import "./NodeService.sol";

contract ParkingTrade {
    
    BCUser bcuser;
    ConstantDef constantDef;
    TableFactory tableFactory;
    NodeService nodeService;
    
    string constant TABLE_NAME = "ParkingTrade_202008191640";
        
    event eventPutTrade(string status,string remark);
    
    constructor() public {
        bcuser = new BCUser();
        constantDef = new ConstantDef(); // 初始化通用合约
        nodeService = new NodeService();
        tableFactory = TableFactory(0x1001);
        tableFactory.createTable(TABLE_NAME, "trade","userId,amount,trade_hash,addTime");
    }

    /*
    	描述 : 获取用户停车缴费记录
    	参数 : 
            userId : 用户标识
    	返回值：
            	参数一： 用户存在返回0, 不存在返回-1
            	参数二： 返回用户停车缴费记录，用户存在时该参数有值
    */
    function select(string userId) public view returns (int256, string[]) {
        string[] memory tradeHash_list;
        Table table = tableFactory.openTable(TABLE_NAME);
        Condition condition = table.newCondition();
        condition.EQ("userId", userId);
        Entries entries = table.select("trade", condition);
                
        if(uint256(entries.size()) == 0) {
            return (-1,tradeHash_list);
        }
        
        tradeHash_list = new string[](uint256(entries.size()));

        for (int256 i = 0; i < entries.size(); ++i) {
            Entry entry = entries.get(i);
            tradeHash_list[uint256(i)] = entry.getString("trade_hash");
        }

        return (0, tradeHash_list);
    }
    
    /*
    	描述 : 验证交易信息是否存在
    	参数 : 
            userId : 资产账户
            trade_hash : 交易hash值
    	返回值：
            	参数一： 存在返回1, 不存在返回-1
    */
    function isExisted(string userId,string trade_hash) public view returns (int256) {
        Table table = tableFactory.openTable(TABLE_NAME);
        Condition condition = table.newCondition();
        condition.EQ("trade_hash", trade_hash);
        condition.EQ("userId", userId);
        Entries entries = table.select("trade", condition);
        if(uint256(entries.size()) == 0){
            return -1;
        }
        return 1;
    }    
    
    /*
    	描述 : 保存用户缴费记录
    	参数 : 
    	    merchantId 商户标识
            userId : 用户标识
            amount : 实付金额
            trade_hash : 缴费记录的hash值
            bookkepping_per 当前新分配的节点记账费
    	返回值：
            	参数一： 
            	    -1 : 缴费记录已存在；
            	     1 ： 缴费记录保存成功；
            	    -2 ：其他异常
    */
    function insert(string merchantId,string userId,uint256 amount,string trade_hash,uint bookkepping_node_manager,uint bookkepping_node_normal) public returns (int256) {
        bool status;
        uint _value;
        if(isExisted(userId,trade_hash) == 1){
            emit eventPutTrade(constantDef.constant1001(),"error");
            return -1;
        }
        Table table = tableFactory.openTable(TABLE_NAME);
        Entry entry = table.newEntry();
        entry.set("userId", userId);
        entry.set("amount", amount);
        entry.set("trade_hash", trade_hash);
        entry.set("addTime", uint256(now));

        int256 count = table.insert("trade", entry);
        if (count == 1) {
            if(amount != 0){
                // 用户创生积分
                bcuser.produceAssetsValue(userId,amount);
                // 分配节点记账费
                nodeService.addNodeBookkepping(userId,trade_hash,bookkepping_node_manager,bookkepping_node_normal); 
            }
            emit eventPutTrade(constantDef.constantSuccess(),"success");
            return 0;
        }else{
            emit eventPutTrade(constantDef.constantOtherError(),"error");
            return -2;
        }
    }
    
    
}
