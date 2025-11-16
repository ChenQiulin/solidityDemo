
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;



contract UserProfileSystem {
    // 用户资料结构体
    struct UserProfile {
        uint id;
        string name;
        uint age;
        address wallet;
        uint[] friendIds; // 好友ID数组
        mapping(uint => bool) isFriend; // 好友关系映射
    }
    
    // 状态变量
    uint public nextUserId = 1;
    mapping(uint => UserProfile) private users;
    mapping(address => uint) public addressToUserId;
        
    // 创建新用户
    function createUser(
        string calldata name, 
        uint age
    ) external returns (uint) {
        require(addressToUserId[msg.sender] == 0, "User already exists");
        
        uint userId = nextUserId++;
        addressToUserId[msg.sender] = userId;
        
        // 初始化用户资料
        UserProfile storage newUser = users[userId];
        newUser.id = userId;
        newUser.name = name;
        newUser.age = age;
        newUser.wallet = msg.sender;
        
        // 初始化空数组
        newUser.friendIds = new uint[](0);
        
        return userId;
    }
    
    // 更新用户资料
    function updateProfile(
        string calldata newName, 
        uint newAge
    ) external {
        uint userId = addressToUserId[msg.sender];
        require(userId != 0, "User not found");
        
        UserProfile storage user = users[userId];
        user.name = newName;
        user.age = newAge;
    }
    
    // 添加好友
    function addFriend(uint friendId) external {
        uint userId = addressToUserId[msg.sender];
        require(userId != 0, "User not found");
        require(friendId != 0 && friendId < nextUserId, "Invalid friend ID");
        require(userId != friendId, "Cannot add yourself");
        
        UserProfile storage user = users[userId];
        require(!user.isFriend[friendId], "Already friends");
        
        // 添加好友关系
        user.friendIds.push(friendId);
        user.isFriend[friendId] = true;
     }
    
    // 删除好友（高效方法）
    function removeFriend(uint friendId) external {
        uint userId = addressToUserId[msg.sender];
        require(userId != 0, "User not found");
        
        UserProfile storage user = users[userId];
        require(user.isFriend[friendId], "Not friends");
        
        // 使用高效删除方法（替换为最后一个元素）
        uint[] storage friends = user.friendIds;
        uint lastIndex = friends.length - 1;
        
        for (uint i = 0; i <= lastIndex; i++) {
            if (friends[i] == friendId) {
                if (i < lastIndex) {
                    friends[i] = friends[lastIndex];
                }
                friends.pop();
                break;
            }
        }
        
        delete user.isFriend[friendId];
    }
    
    // 获取用户资料（返回结构体部分数据）
    function getUserProfile(uint userId) public view returns (
        uint id,
        string memory name,
        uint age,
        address wallet,
        uint friendCount
    ) {
        UserProfile storage user = users[userId];
        require(user.id != 0, "User not found");
        
        return (
            user.id,
            user.name,
            user.age,
            user.wallet,
            user.friendIds.length
        );
    }
    
    // 获取好友列表（返回内存数组）
    function getFriends(uint userId) public view returns (uint[] memory) {
        UserProfile storage user = users[userId];
        require(user.id != 0, "User not found");
        
        // 返回内存副本
        return user.friendIds;
    }
    
    // 检查好友关系
    function isFriend(uint userId, uint friendId) public view returns (bool) {
        return users[userId].isFriend[friendId];
    }
}
