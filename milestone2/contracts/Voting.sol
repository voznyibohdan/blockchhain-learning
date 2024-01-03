pragma solidity ^0.8.19;

import "./MyToken.sol";

contract Voting is MyToken {
    mapping(address => bool) private _voters;
    mapping(uint256 => uint256) private _priceWeight;

    uint256[] private _proposedPrices;

    uint256 private _leadingPrice;
    uint256 private _votingEndTime;
    uint256 private constant _timeToVote;

    event VotingStarted(uint256 startTime, uint256 endTime);
    event Voted(address indexed voter, uint256 price, uint256 votes);
    event VotingEnded(uint256 endTime, uint256 price);

    modifier hasMinimumBalance(uint256 percentage) {
        require(balances[msg.sender] >= (totalSupply * percentage), "Insufficient balance to execute this function");
        _;
    }

    function startVoting() external hasMinimumBalance(0.1) {
        require(!isVotingInProgress, "Voting already in progress");

        isVotingInProgress = true;
        _votingEndTime = block.timestamp + _timeToVote;
        emit VotingStarted(block.timestamp, _votingEndTime);
    }

    function vote(uint256 price) external canVote hasMinimumBalance(minTokenAmount) {
        require(!_voters[msg.sender], "Already voted");

        if (!_priceWeight[price]) _proposedPrices.push(price);
        if (!_voters[msg.sender]) votersList.push(msg.sender);

        _priceWeight[price] += _priceWeight[price].add(balances[msg.sender]);
        _voters[msg.sender] = true;

        if (_priceWeight[price] >= _priceWeight[_leadingPrice]) {
            _leadingPrice = price;
        }

        emit Voted(msg.sender, price, addressToBalance[msg.sender]);
    }

    function endVoting() external onlyOwner {
        require(block.timestamp > _votingEndTime, "Voting period not ended yet");

        tokenPrice = _leadingPrice;
        emit VotingEnded(block.timestamp, _leadingPrice);

        _leadingPrice = 0;

        for (uint256 i = 0; i < _proposedPrices.length; i++) {
            uint256 price = _proposedPrices[i];
            _priceWeight[price] = 0;
        }

        for (uint256 i = 0; i < votersList.length; i++) {
            uint256 voter = votersList[i];
            _voters[voter] = false;
        }

        delete votersList;
        delete _proposedPrices;
    }
}
