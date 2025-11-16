
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;



contract SenderDemo {
    address public lastCaller;
    
    function recordCaller() public {
        // 记录调用者地址
        lastCaller = msg.sender;
    }
    
    // 合约调用示例
    function callFromContract(address otherContract) public {
        Other other = Other(otherContract);
        other.call();
    }
}

contract Other {
    address public lastCaller;

    function call() external {
        lastCaller = msg.sender;
    }
}
