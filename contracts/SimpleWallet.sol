
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;


contract SimpleWallet {
    // 所有者地址
    address payable public owner;
    
    // 事件记录
    event Received(address indexed sender, uint amount);
    event Withdrawn(address indexed recipient, uint amount);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    
    // 构造函数：设置所有者
    constructor() payable {
        owner = payable(msg.sender);
    }
    
    // 修饰符：仅所有者
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }
    
    // 接收ETH（外部账户或transfer/send调用）
    receive() external payable {
        emit Received(msg.sender, msg.value);
    }
    
    // 接收ETH（call调用）
    fallback() external payable {
        emit Received(msg.sender, msg.value);
    }
    
    // 获取合约余额
    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
    
    // 提款功能（仅所有者）
    function withdraw(uint amount) public onlyOwner {
        require(amount <= address(this).balance, "Insufficient balance");
        
        // 安全转账 - 使用transfer
        owner.transfer(amount);
        
        emit Withdrawn(owner, amount);
    }
    
    // 向指定地址转账（仅所有者）
    function transferTo(address payable recipient, uint amount) public onlyOwner {
        require(amount <= address(this).balance, "Insufficient balance");
        
        // 更灵活的call方法（适合合约交互）
        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Transfer failed");
        
        emit Withdrawn(recipient, amount);
    }
    
    // 转移所有权（仅所有者）
    function transferOwnership(address payable newOwner) public onlyOwner {
        require(newOwner != address(0), "Invalid address");
        
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
    
    // 紧急自毁（仅所有者）
    function destroy() public onlyOwner {
        // 转移剩余资金
        owner.transfer(address(this).balance);
        
        // 销毁合约
        selfdestruct(owner);
    }
}
