pragma solidity ^0.4.25;

contract ConstantDef {
    
    // 1001 ��ѯ��Ӧ�ļ�¼�Ѵ���
    function constant1001() public view returns(string) {
        return "1001";
    }
    
    // 1002 ��ѯ��Ӧ�ļ�¼������
    function constant1002() public view returns(string) {
        return "1002";
    }
    
    // 0000 �����ɹ�
    function constantSuccess() public view returns(string) {
        return "0000";
    }
    
    // 7001 �����쳣
    function constantOtherError() public view returns(string) {
        return "7001";
    }
    
}

