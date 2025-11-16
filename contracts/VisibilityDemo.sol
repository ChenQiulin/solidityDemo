contract VisibilityDemo {
    // 公共函数（合约内外均可调用）
    function publicFunc() public pure returns (string memory) {
        return "Public function";
    }
    
    // 私有函数（仅本合约内部可调用）
    function privateFunc() private pure returns (string memory) {
        return "Private function";
    }
    
    // 内部函数（本合约及继承合约可调用）
    function internalFunc() internal pure returns (string memory) {
        return "Internal function";
    }
    
    // 外部函数（仅能从合约外部调用）
    function externalFunc() external pure returns (string memory) {
        return "External function";
    }
    
    // 测试调用
    function testCalls() public pure returns(string memory p, string memory v, string memory i){
        p = publicFunc();       // 正确
        v = privateFunc();      // 正确（同一合约内）
        i = internalFunc();     // 正确
        //externalFunc();  // 错误！不能在内部调用外部函数
    }
}

contract Child is VisibilityDemo {
    function callParent() public pure {
        publicFunc();       // 正确
        //privateFunc();   // 错误！私有函数不可继承
        internalFunc();     // 正确
        //externalFunc();  // 错误！不能在内部调用外部函数
    }
}

contract Other {
    VisibilityDemo visi;
    constructor() {
        visi = new VisibilityDemo();
    }
    function call() public returns(string memory){
        return visi.externalFunc();
    }
}
