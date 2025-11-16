contract ModifierDemo {
    address public owner;
    uint public minAmount = 1 ether;
    
    constructor() {
        owner = msg.sender;
    }
    
    // 自定义修饰符：仅所有者可调用
    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner!");
        _; // 继续执行函数体
    }
    
    // 自定义修饰符：验证最小金额
    modifier minValue(uint amount) {
        require(msg.value >= amount, "Value too low");
        _;
    }
    
    // 组合修饰符
    function changeOwner(address newOwner) public onlyOwner {
        owner = newOwner;
    }
    
    // 带参数的修饰符
    function deposit() public payable minValue(minAmount) {
        // 接收ETH
    }
    
    // 修改修饰符参数
    function setMinAmount(uint amount) public onlyOwner {
        minAmount = amount;
    }
}
