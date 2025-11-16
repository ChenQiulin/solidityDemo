


// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;



contract MutabilityDemo {
    uint public stateVar = 100;
    
    // view函数：可读取状态，不可修改
    function getState() public view returns (uint) {
        return stateVar; // 允许读取状态
        // stateVar = 200; // 禁止修改状态
    }
    
    // pure函数：不可读写状态
    function pureAdd(uint a, uint b) public pure returns (uint) {
        return a + b;
        // return stateVar + a; // 禁止访问状态
    }
    
    // payable函数：可接收ETH
    function deposit() public payable {
        // 可通过address(this).balance访问余额
    }
    
    // 无修饰符：可修改状态
    function changeState() public {
        stateVar = 200;
    }
}
