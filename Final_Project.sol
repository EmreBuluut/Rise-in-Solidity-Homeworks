// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract VotingSystem {
    uint256 private counter;
    address[] private voted_addresses;
    address private owner;

    struct Proposal {
        string title;
        string description;
        uint256 approve;
        uint256 reject;
        uint256 pass;
        uint256 voteThreshold; 
        bool is_active;   
    }
    
    Proposal[] private proposal_history;
    mapping(address => bool) private hasVoted;

    modifier hasnotVoted() {
       require(!hasVoted[msg.sender], "You have already voted");
       _; 
    }
    modifier onlyOwner() {
        require(msg.sender == owner, "Only contract owner can call this function");
        _;
    }

    modifier checkVoteCount(uint256 _proposalIndex, uint256 _voteCountThreshold) {
        require(proposal_history[_proposalIndex].approve + proposal_history[_proposalIndex].reject + proposal_history[_proposalIndex].pass >= _voteCountThreshold, "Vote count threshold not reached");
        _;
    }
    
    modifier active() {
        require(proposal_history[counter].is_active, "Proposal is not active");
        _;
    }

    constructor() {
        owner = msg.sender;
    }
        function costomize(string calldata _title, string calldata _description, uint256  _voteThreshold) external onlyOwner {
        counter += 1;
        proposal_history[counter] = Proposal(_title, _description, 0, 0, 0, _voteThreshold, true);
    }
        function setOwner(address new_owner) external onlyOwner {
        owner = new_owner;
    }

    function vote(uint256 _proposalIndex, uint8 _voteType) external {
        require(_proposalIndex < proposal_history.length, "Invalid proposal index");
        require(proposal_history[_proposalIndex].is_active, "Proposal is not active"); 
        
        hasVoted[msg.sender] = true;
        voted_addresses.push(msg.sender);

        if (_voteType == 1) {
            proposal_history[_proposalIndex].approve++;
        } else if (_voteType == 2) {
            proposal_history[_proposalIndex].reject++;
        } else if (_voteType == 3) {
            proposal_history[_proposalIndex].pass++;
        } else {
            revert("Invalid vote type");
        }

  
        uint256 totalVotes = proposal_history[_proposalIndex].approve + proposal_history[_proposalIndex].reject + proposal_history[_proposalIndex].pass;
        uint256 voteThreshold = proposal_history[_proposalIndex].voteThreshold; 
        if (totalVotes >= voteThreshold) {
            proposal_history[_proposalIndex].is_active = false; 
        }
    }

    function calculateCurrentState(uint256 _proposalIndex) private view returns(bool) {
        Proposal storage proposal = proposal_history[_proposalIndex];

        uint256 approve = proposal.approve;
        uint256 reject = proposal.reject;
        uint256 pass = proposal.pass;
        uint256 totalVotes = approve + reject + pass;
        uint256 decisiveVote = (approve + reject);

        require(totalVotes > 0, "No votes cast yet");

         if ((proposal.approve + proposal.reject)%2 == 1){
            (decisiveVote) += 1;
        }
        (decisiveVote) =  (decisiveVote)/2;

        if (approve > reject && pass <= decisiveVote) {
            return true;
        } else {
            return false;
        }
    }

    function terminateProposal() external onlyOwner active {
        proposal_history[counter].is_active = false;
    }

    function getCurrentProposal() external view returns (string memory title, string memory description, uint256 approve, uint256 reject, uint256 pass) {
        Proposal storage currentProposal = proposal_history[counter];
        return (currentProposal.title, currentProposal.description, currentProposal.approve, currentProposal.reject, currentProposal.pass);
    }

    function getProposal(uint256 number) external view returns (string memory title, string memory description, uint256 approve, uint256 reject, uint256 pass) {
        Proposal storage requestedProposal = proposal_history[number];
        return (requestedProposal.title, requestedProposal.description, requestedProposal.approve, requestedProposal.reject, requestedProposal.pass);
    }
}
