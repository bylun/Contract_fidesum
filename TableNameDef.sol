pragma solidity ^0.4.25;

contract TableNameDef {
    
    string private TABLE_NAME_MERCHANT;
    string private TABLE_NAME_STATICSTIC;
    string private TABLE_NAME_MerchantNewUserValueDetail;
    string private TABLE_NAME_ParkingTrade;
    string private TABLE_NAME_BCUSER;
    string private TABLE_NAME_NODE_BOOKKEPPINGDETAIL;
    string private TABLE_NAME_NODEACCOUNT;
    string private TABLE_NAME_BLOCKCHAIN_MANAGER;
    
    // 初始化
    constructor() public {
        TABLE_NAME_MERCHANT = "merchant_202008191640";
        TABLE_NAME_STATICSTIC = "statistic_202008191640";
        TABLE_NAME_MerchantNewUserValueDetail = "merchant_newUserValue_detail_202008281340";
        TABLE_NAME_ParkingTrade = "ParkingTrade_202008191640";
        TABLE_NAME_BCUSER = "BCUser_202008191640";
        TABLE_NAME_NODE_BOOKKEPPINGDETAIL = "node_bookkepping_detail_202008191640";
        TABLE_NAME_NODEACCOUNT = "node_service_202008191640";
        TABLE_NAME_BLOCKCHAIN_MANAGER = "bcmanager_202008191640";
    }
    
    // 商户服务合约表名
    function constantMerchantService() public view returns(string) {
        return TABLE_NAME_MERCHANT;
    }
    
    // 统计合约表名
    function constantStatisticService() public view returns(string) {
        return TABLE_NAME_STATICSTIC;
    }
    
    // 商户开户奖明细合约表名
    function constantMerchantNewUserValueDetail() public view returns(string) {
        return TABLE_NAME_MerchantNewUserValueDetail;
    }
    
    // 停车交易合约表名
    function constantParkingTrade() public view returns(string) {
        return TABLE_NAME_ParkingTrade;
    }
    
    // 用户合约表名
    function constantBCUser() public view returns(string) {
        return TABLE_NAME_BCUSER;
    }
    
    // 节点记账费明细合约表名
    function constantNodeBookkeeppingDetail() public view returns(string) {
        return TABLE_NAME_NODE_BOOKKEPPINGDETAIL;
    }
    
    // 节点服务合约表名
    function constantNodeService() public view returns(string) {
        return TABLE_NAME_NODEACCOUNT;
    }
    
    // 区块链管理务合约表名
    function constantBCManager() public view returns(string) {
        return TABLE_NAME_BLOCKCHAIN_MANAGER;
    }
    
    
    
    
    
    
    
}