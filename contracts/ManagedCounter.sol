
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;


contract ManagedCounter {
    // 状态变量
    uint private count;
    address public owner;
    mapping(address => bool) public operators;
    
    // 事件
    event CountChanged(uint newValue, address changer);
    event OperatorAdded(address operator);
    event OperatorRemoved(address operator);
    
    // 构造函数
    constructor() {
        owner = msg.sender;
        operators[msg.sender] = true; // 默认添加部署者为操作员
    }
    
    // 修饰符：仅所有者
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }
    
    // 修饰符：仅操作员
    modifier onlyOperator() {
        require(operators[msg.sender], "Only operator can perform this action");
        _;
    }
    
    // 添加操作员（仅所有者）
    function addOperator(address operator) public onlyOwner {
        operators[operator] = true;
        emit OperatorAdded(operator);
    }
    
    // 移除操作员（仅所有者）
    function removeOperator(address operator) public onlyOwner {
        operators[operator] = false;
        emit OperatorRemoved(operator);
    }
    
    // 获取当前计数（view函数）
    function getCount() public view returns (uint) {
        return count;
    }
    
    // 增加计数（仅操作员）
    function increment() public onlyOperator {
        count++;
        emit CountChanged(count, msg.sender);
    }
    
    // 减少计数（仅操作员，防止下溢）
    function decrement() public onlyOperator {
        require(count > 0, "Count cannot be negative");
        count--;
        emit CountChanged(count, msg.sender);
    }
    
    // 重置计数（仅所有者）
    function reset() public onlyOwner {
        count = 0;
        emit CountChanged(count, msg.sender);
    }
    
    // 带参数的计数设置（条件判断）
    function setCount(uint newValue) public onlyOperator {
        // 条件检查
        if (newValue > 100) {
            // 特殊处理：超过100需所有者批准
            require(msg.sender == owner, "Owner approval required for values > 100");
            count = newValue;
        } else if (newValue < 50) {
            // 循环设置（演示循环使用）
            uint diff;
            if (newValue > count) {
                diff = newValue - count;
                for (uint i = 0; i < diff; i++) {
                    increment(); // 调用其他函数
                }
            } else {
                diff = count - newValue;
                for (uint i = 0; i < diff; i++) {
                    decrement();
                }
            }
        } else {
            // 直接设置
            count = newValue;
        }
        
        emit CountChanged(count, msg.sender);
    }
}
