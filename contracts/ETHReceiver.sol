
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

contract ETHReceiver {
    // 事件日志
    event EtherReceived(address indexed sender, uint amount, uint timestamp);
    event FallbackTriggered(address indexed sender, uint amount, bytes data, uint timestamp);
    event Withdrawal(address indexed recipient, uint amount, uint timestamp);
    
    // 状态变量
    address payable public owner;
    uint public totalReceived;
    uint public totalWithdrawn;
    
    // 防止重入攻击
    bool private locked;
    modifier nonReentrant() {
        require(!locked, "ReentrancyGuard: reentrant call");
        locked = true;
        _;
        locked = false;
    }
    
    // 构造函数 - 设置合约所有者
    constructor() {
        owner = payable(msg.sender);
    }
    
    // 接收纯ETH转账
    receive() external payable {
        _processPayment(msg.sender, msg.value, "");
    }
    
    // 接收带数据ETH转账或未知函数调用
    fallback() external payable {
        _processPayment(msg.sender, msg.value, msg.data);
    }
    
    // 处理支付逻辑
    function _processPayment(address sender, uint amount, bytes memory data) private {
        require(amount > 0, "Payment amount must be greater than 0");
        totalReceived += amount;
        
        if (data.length == 0) {
            emit EtherReceived(sender, amount, block.timestamp);
        } else {
            emit FallbackTriggered(sender, amount, data, block.timestamp);
        }
    }
    
    // 提取ETH（仅所有者）
    function withdraw(uint amount) external nonReentrant {
        require(msg.sender == owner, "Only owner can withdraw");
        require(amount <= address(this).balance, "Insufficient balance");
        
        totalWithdrawn += amount;
        owner.transfer(amount);
        
        emit Withdrawal(owner, amount, block.timestamp);
    }
    
    // 获取合约余额
    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
    
    // 获取合约信息
    function getContractInfo() public view returns (
        address, uint, uint, uint
    ) {
        return (
            owner,
            address(this).balance,
            totalReceived,
            totalWithdrawn
        );
    }
    
    // 转移所有权（仅所有者）
    function transferOwnership(address payable newOwner) public {
        require(msg.sender == owner, "Only owner can transfer ownership");
        require(newOwner != address(0), "Invalid address");
        
        owner = newOwner;
    }
}
