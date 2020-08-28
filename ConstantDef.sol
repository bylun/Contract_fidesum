pragma solidity ^0.4.25;

contract ConstantDef {
    
    // 1001 查询对应的记录已存在
    function constant1001() public view returns(string) {
        return "1001";
    }
    
    // 1002 查询对应的记录不存在
    function constant1002() public view returns(string) {
        return "1002";
    }
    
    // 0000 操作成功
    function constantSuccess() public view returns(string) {
        return "0000";
    }
    
    // 7001 其它异常
    function constantOtherError() public view returns(string) {
        return "7001";
    }
    
}

