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
    
    // ��ʼ��
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
    
    // �̻������Լ����
    function constantMerchantService() public view returns(string) {
        return TABLE_NAME_MERCHANT;
    }
    
    // ͳ�ƺ�Լ����
    function constantStatisticService() public view returns(string) {
        return TABLE_NAME_STATICSTIC;
    }
    
    // �̻���������ϸ��Լ����
    function constantMerchantNewUserValueDetail() public view returns(string) {
        return TABLE_NAME_MerchantNewUserValueDetail;
    }
    
    // ͣ�����׺�Լ����
    function constantParkingTrade() public view returns(string) {
        return TABLE_NAME_ParkingTrade;
    }
    
    // �û���Լ����
    function constantBCUser() public view returns(string) {
        return TABLE_NAME_BCUSER;
    }
    
    // �ڵ���˷���ϸ��Լ����
    function constantNodeBookkeeppingDetail() public view returns(string) {
        return TABLE_NAME_NODE_BOOKKEPPINGDETAIL;
    }
    
    // �ڵ�����Լ����
    function constantNodeService() public view returns(string) {
        return TABLE_NAME_NODEACCOUNT;
    }
    
    // �������������Լ����
    function constantBCManager() public view returns(string) {
        return TABLE_NAME_BLOCKCHAIN_MANAGER;
    }
    
    
    
    
    
    
    
}