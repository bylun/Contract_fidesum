pragma solidity ^0.4.25;

contract BCManagerUtil {
    
    // ͨ����ʼ��ֵ - 4������
    uint _tonglian_productSumLimit; 
    // ͨ����ʼ��ֵ - 60�������Ʊ���
    uint _tonglian_monthLimit;
    
    
    // ����ʱ��ʼ������ֵ
    constructor() public {
        _tonglian_productSumLimit = 400000000*100*10; // 4��*100 ��������ҵ�λ���֡���ֵ������������������С����ͨ����ʼ��ֵ0.5TB��Ҫ����10�֣�����4��*100*10�ɵȵ�λ�����ں�������
        _tonglian_monthLimit = now + 30*60 days; // �ӵ�ǰʱ�俪ʼ������60����
    }
    
    /*
        ����������
            ��ǰʱ���tonglian_monthLimit�Ƚ�
        ������
            account_iniValue ͨ����ʼ��ֵ
        ����ֵ��
            bool : С��60���·��� 'true'�����򷵻� 'false'
    */
    function isPassedTonglian_monthLimit() public view returns (bool) {
      return (now <= _tonglian_monthLimit);
    }
    
    /*
        ����������
            ͨ����ʼ��ֵ��������
        ������
            account_iniValue ͨ����ʼ��ֵ
        ����ֵ��
            bool : С�����ڷ���'true' �����򷵻� 'false'
    */
    function isPassedProductSumLimit(uint account_iniValue) public view returns (bool) {
        return (_tonglian_productSumLimit <= account_iniValue);
    }
    
    /*
        ����������
            ͨ����ʼ��ֵ
        ������
            tradeAmount ���׽��
            iniValue ͨ���˻��еĴ�ʼ��ֵ
            maintainValue ������ά����
        ����ֵ��
            ����0ʱͨ����ֵ�������䣬Ϊ0ʱ���ﵽ��ʼ��ֵ���� ֹͣ���䡣
    */
    function countValue(uint tradeAmount,uint iniValue,uint maintainValue) public view returns (bool,uint){
        uint _initValue;
        uint _maintainValue;
        if(isPassedTonglian_monthLimit() || isPassedProductSumLimit(iniValue)){
            _initValue = tradeAmount * 5; // ����õ����������С10��������ҵ�λ���֡����
            return (true,_initValue);
        }else{
            _maintainValue = tradeAmount * 5 ; // ����õ����������С100��������ҵ�λ���֡����
            return (false,_maintainValue);
        }
        
    }
    
  
}