
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;


contract TransferDemo {
   constructor() payable {    }
    // 接收ETH（用于测试）
    receive() external payable {}
    
    // 使用transfer（推荐）
    function safeTransfer(address payable to, uint amount) public {
        to.transfer(amount); //2300gas
    }
    
    // 使用send（不推荐）
    function unsafeSend(address payable to, uint amount) public returns (bool) {
        bool success = to.send(amount);
        require(success, "Send failed");
        return success;
    }
    
    // 使用call（灵活但需谨慎）
    function flexibleCall(address payable to, uint amount) public {
        (bool success, ) = to.call{value: amount}("");
        require(success, "Call failed");
    }
    
    // 获取余额
    function getBalance(address account) public view returns (uint) {
        return account.balance;
    }
    
    // 危险示例：直接赋值
    function dangerousAssignment(address to) public {
        // 编译错误：新版本Solidity已禁止
        // to.transfer(5 ether);
    }
}
