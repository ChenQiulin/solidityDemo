// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VotingSystem {
    // 投票状态
    enum VotingStatus { 
        Pending,    // 0 - 未开始
        Active,     // 1 - 进行中
        Completed   // 2 - 已完成
    }
    
    // 提案结构
    struct Proposal {
        string name;        // 提案名称
        uint voteCount;     // 得票数
    }
    
    // 投票者结构
    struct Voter {
        bool voted;         // 是否已投票
        address delegate;   // 委托投票地址
        uint voteIndex;     // 投票的提案索引
    }
    
    // 投票信息
    address public chairperson;  // 投票发起人
    VotingStatus public status;  // 当前状态
    uint public startTime;       // 开始时间
    uint public duration;        // 投票持续时间(秒)
    Proposal[] public proposals; // 提案列表
    mapping(address => Voter) public voters; // 投票者映射
    
    // 事件
    event VoteStarted(uint startTime, uint duration);
    event VoteCasted(address indexed voter, uint proposalIndex);
    event VoteDelegated(address indexed from, address indexed to);
    event VoteCompleted(uint winningProposalIndex);
    
    // 修饰符：仅发起人
    modifier onlyChairperson() {
        require(msg.sender == chairperson, "Only chairperson can perform this action");
        _;
    }
    
    // 修饰符：特定投票状态
    modifier onlyStatus(VotingStatus requiredStatus) {
        require(status == requiredStatus, "Invalid voting status");
        _;
    }
    
    // 构造函数：创建投票
    constructor(string[] memory proposalNames) {
        chairperson = msg.sender;
        status = VotingStatus.Pending;
        
        // 初始化提案
        for (uint i = 0; i < proposalNames.length; i++) {
            proposals.push(Proposal({
                name: proposalNames[i],
                voteCount: 0
            }));
        }
    }
    
    // 开始投票（仅发起人）
    function startVote(uint _duration) public onlyChairperson onlyStatus(VotingStatus.Pending) {
        status = VotingStatus.Active;
        startTime = block.timestamp;
        duration = _duration;
        emit VoteStarted(startTime, duration);
    }
    
    // 委托投票权
    function delegate(address to) public onlyStatus(VotingStatus.Active) {
        require(block.timestamp < startTime + duration, "Voting period has ended");
        
        Voter storage sender = voters[msg.sender];
        require(!sender.voted, "You already voted");
        require(to != msg.sender, "Self-delegation is disallowed");
        
        // 查找最终委托地址（避免委托循环）
        address currentDelegate = to;
        while (voters[currentDelegate].delegate != address(0)) {
            currentDelegate = voters[currentDelegate].delegate;
            require(currentDelegate != msg.sender, "Found delegation loop");
        }
        
        // 执行委托
        sender.voted = true;
        sender.delegate = to;
        emit VoteDelegated(msg.sender, to);
        
        // 如果被委托人已投票，增加票数
        Voter storage delegateVoter = voters[currentDelegate];
        if (delegateVoter.voted) {
            proposals[delegateVoter.voteIndex].voteCount++;
        }
    }
    
    // 投票
    function vote(uint proposalIndex) public onlyStatus(VotingStatus.Active) {
        require(block.timestamp < startTime + duration, "Voting period has ended");
        
        Voter storage sender = voters[msg.sender];
        require(!sender.voted, "Already voted");
        require(proposalIndex < proposals.length, "Invalid proposal index");
        
        sender.voted = true;
        sender.voteIndex = proposalIndex;
        proposals[proposalIndex].voteCount++;
        
        emit VoteCasted(msg.sender, proposalIndex);
    }
    
    // 结束投票并统计结果（仅发起人）
    function endVote() public onlyChairperson onlyStatus(VotingStatus.Active) {
        require(block.timestamp >= startTime + duration, "Voting period not ended");
        
        status = VotingStatus.Completed;
        
        // 找出获胜提案
        uint winningProposalIndex = findWinningProposal();
        emit VoteCompleted(winningProposalIndex);
    }
    
    // 获取获胜提案索引
    function winningProposalIndex() public view onlyStatus(VotingStatus.Completed) returns (uint) {
        return findWinningProposal();
    }
    
    // 获取获胜提案名称
    function winnerName() public view onlyStatus(VotingStatus.Completed) returns (string memory) {
        uint index = findWinningProposal();
        return proposals[index].name;
    }
    
    // 内部函数：找出获胜提案
    function findWinningProposal() internal view returns (uint winningIndex) {
        uint winningVoteCount = 0;
        
        // 遍历所有提案找出最高票
        for (uint i = 0; i < proposals.length; i++) {
            if (proposals[i].voteCount > winningVoteCount) {
                winningVoteCount = proposals[i].voteCount;
                winningIndex = i;
            }
        }
        
        // 检查是否有平票（返回第一个达到最高票的提案）
        return winningIndex;
    }
    
    // 获取投票状态
    function getVotingStatus() public view returns (string memory) {
        if (status == VotingStatus.Pending) return "Pending";
        if (status == VotingStatus.Active) {
            if (block.timestamp < startTime + duration) {
                return "Active";
            }
            return "Active (Ending Soon)";
        }
        return "Completed";
    }
    
    // 获取剩余投票时间
    function getRemainingTime() public view onlyStatus(VotingStatus.Active) returns (uint) {
        if (block.timestamp >= startTime + duration) return 0;
        return (startTime + duration) - block.timestamp;
    }
}

