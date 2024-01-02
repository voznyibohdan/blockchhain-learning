pragma solidity ^0.8.0;

import "./Token.sol";

contract Voting is Token {
    uint256 public currentHighestTokenPrice;

    mapping(uint256 => uint256) public votingPriceWeight;
    address[] public voters;
    uint256[] public proposedPrices;

    event VotingStarted(uint256 startTime, uint256 endTime);
    event Voted(address indexed voter, uint256 price, uint256 votes);
    event VotingEnded(uint256 endTime, uint256 price);

    modifier canStartVoting() {
        require(!votingIsInProgress, "Voting already in progress");
        _;
    }

    modifier hasMinimumBalance(uint256 percentage) {
        require(
            addressToBalance[msg.sender] >= (totalSupply * percentage),
            "Insufficient balance to execute this function"
        );
        _;
    }

    function startVoting() external canStartVoting hasMinimumBalance(0.1) {
        votingIsInProgress = true;
        emit VotingStarted(block.timestamp, block.timestamp + timeToVote);
    }

    function vote(uint256 price) external hasMinimumBalance(0.05) {
        if (!votingPriceWeight[price]) {
            proposedPrices.push(price);
        }

        votingPriceWeight[price] += addressToBalance[msg.sender];
        voters.push(msg.sender);

        if (votingPriceWeight[price] > votingPriceWeight[currentHighestTokenPrice]) {
            currentHighestTokenPrice = price;
        }

        emit Voted(msg.sender, price, addressToBalance[msg.sender]);
    }

    function endVoting() external onlyOwner {
        require(block.timestamp > timeToVote, "Voting period not ended yet");

        tokenPrice = currentHighestTokenPrice;
        emit VotingEnded(block.timestamp, currentHighestTokenPrice);

        _resetVotingState();
    }

    function _resetVotingState() private {
        currentHighestTokenPrice = 0;

        for(uint256 i = 0; i < proposedPrices.length; i++) {
            uint256 price = proposedPrices[i];
            votingPriceWeight[price] = 0;
        }

        delete voters;
        delete proposedPrices;
    }
}
