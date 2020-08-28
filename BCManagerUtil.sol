pragma solidity ^0.4.25;

contract BCManagerUtil {
    
    // 通链创始价值 - 4亿限制
    uint _tonglian_productSumLimit; 
    // 通链创始价值 - 60个月限制变量
    uint _tonglian_monthLimit;
    
    
    // 部署时初始化并赋值
    constructor() public {
        _tonglian_productSumLimit = 400000000*100*10; // 4亿*100 即与人民币单位‘分’等值，由于区块链不存在小数，通链创始价值0.5TB需要扩大10分，所以4亿*100*10成等单位，便于后续计算
        _tonglian_monthLimit = now + 30*60 days; // 从当前时间开始往后推60个月
    }
    
    /*
        函数描述：
            当前时间和tonglian_monthLimit比较
        参数：
            account_iniValue 通链创始价值
        返回值：
            bool : 小于60个月返回 'true'，否则返回 'false'
    */
    function isPassedTonglian_monthLimit() public view returns (bool) {
      return (now <= _tonglian_monthLimit);
    }
    
    /*
        函数描述：
            通链创始价值四亿限制
        参数：
            account_iniValue 通链创始价值
        返回值：
            bool : 小于四亿返回'true' ，否则返回 'false'
    */
    function isPassedProductSumLimit(uint account_iniValue) public view returns (bool) {
        return (_tonglian_productSumLimit <= account_iniValue);
    }
    
    /*
        函数描述：
            通链创始价值
        参数：
            tradeAmount 交易金额
            iniValue 通链账户中的创始价值
            maintainValue 区块链维护费
        返回值：
            大于0时通链价值继续分配，为0时即达到创始价值条件 停止分配。
    */
    function countValue(uint tradeAmount,uint iniValue,uint maintainValue) public view returns (bool,uint){
        uint _initValue;
        uint _maintainValue;
        if(isPassedTonglian_monthLimit() || isPassedProductSumLimit(iniValue)){
            _initValue = tradeAmount * 5; // 计算得到结果后在缩小10倍与人民币单位‘分’相等
            return (true,_initValue);
        }else{
            _maintainValue = tradeAmount * 5 ; // 计算得到结果后在缩小100倍与人民币单位‘分’相等
            return (false,_maintainValue);
        }
        
    }
    
  
}