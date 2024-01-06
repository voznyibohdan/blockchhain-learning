// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "./StorageContract.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract ImplContract is StorageContract, IERC20 {
    modifier onlyAfterVoting() {
        require(
            (!isVotingInProgress && (voters[msg.sender] != votingId)),
            "Cant perform operation while voting is active"
        );
        _;
    }

    modifier hasMinimumBalance(uint256 percentage) {
        require(
            balances[msg.sender] >= ((tokenTotalSupply * percentage) / 10000),
            "Insufficient balance to execute this function"
        );
        _;
    }

    modifier validDestination(address to) {
        require(to != address(0x0));
        require(to != address(this));
        _;
    }

    event VotingStarted(uint256 startTime, uint256 endTime);
    event Voted(address indexed voter, uint256 price, uint256 votes);
    event VotingEnded(uint256 endTime, uint256 price);
    event Burn(address indexed from, uint256 value);

    // IERC20 Interface
    function totalSupply() external view returns(uint256) {
        return tokenTotalSupply;
    }

    function balanceOf(address account) external view override returns (uint256) {
        return balances[account];
    }

    function transfer(address to, uint256 amount) external override onlyAfterVoting validDestination(to) returns (bool) {
        require(balances[msg.sender] >= amount, "Insufficient balance");

        balances[msg.sender] -= amount;
        balances[to] += amount;

        emit Transfer(msg.sender, to, amount);
        return true;
    }

    function allowance(address owner, address spender) external view override returns (uint256) {
        return allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) external override returns (bool) {
        allowances[msg.sender][spender] = amount;

        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) external override onlyAfterVoting validDestination(to) returns (bool) {
        require(balances[from] >= amount, "Insufficient balance");
        require(allowances[from][msg.sender] >= amount, "Insufficient allowance");

        balances[from] -= amount;
        balances[to] += amount;
        allowances[from][msg.sender] -= amount;

        emit Transfer(from, to, amount);
        return true;
    }

    // StorageContract.sol functions
    function _mint(address account, uint256 amount) private {
        balances[account] += amount;
        tokenTotalSupply += amount;

        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) private {
        require(balances[account] >= amount, "Insufficient balance for burning");

        balances[account] -= amount;
        tokenTotalSupply -= amount;

        emit Burn(account, amount);
    }

    function burnFee() external {
        require((block.timestamp - 1 weeks) >= lastFeeBurnDate);
        lastFeeBurnDate = block.timestamp;
        feePool = 0;
    }

    // Voting functions
    function startVoting(uint256 price) external hasMinimumBalance(1) {
        require(!isVotingInProgress, "Voting already in progress");

        votingId++;
        voters[msg.sender] = votingId;
        isVotingInProgress = true;
        votingEndTime = block.timestamp + timeToVote;
        prices[price] = Price({ votingId: votingId, weight: balances[msg.sender] });

        emit VotingStarted(block.timestamp, votingEndTime);
    }

    function vote(uint256 price) external hasMinimumBalance(minTokenAmount) {
        require(isVotingInProgress, "Voting has not started yet");
        require(voters[msg.sender] != votingId, "Already voted");

        voters[msg.sender] = votingId;

        if (prices[price].votingId == votingId) {
            prices[price].weight += balances[msg.sender];
        } else {
            prices[price] = Price({ votingId : votingId, weight : balances[msg.sender] });
        }

        if (prices[price].weight >= prices[leadingPrice].weight) {
            leadingPrice = price;
        }

        emit Voted(msg.sender, price, balances[msg.sender]);
    }

    function endVoting() external {
        require((isVotingInProgress) && (block.timestamp > votingEndTime), "Voting period not ended yet");

        tokenPrice = leadingPrice;
        emit VotingEnded(block.timestamp, leadingPrice);

        leadingPrice = 0;
    }

    // Transactions functions
    function buy(uint256 amount) external payable {
        (uint256 ethCost, uint256 fee) = _calculateCost(amount);
        uint256 totalCost = ethCost + fee;

        require(msg.value >= totalCost, "Insufficient funds sent");

        _mint(msg.sender, amount);
        etherPool += ethCost;
        feePool += fee;
    }

    function sell(uint256 amount) external payable onlyAfterVoting {
        require(balances[msg.sender] >= amount, "Insufficient tokens");

        (uint256 ethCost, uint256 fee) = _calculateCost(amount);
        uint256 earned = ethCost - fee;

        etherPool -= earned;

        _burn(msg.sender, amount);
        payable(msg.sender).transfer(earned);
    }

    function _calculateCost(uint256 tokenAmount) private view returns (uint256, uint256) {
        uint256 ethCost = tokenAmount * tokenPrice;
        uint256 fee = (ethCost * feePercentage) / 10_000;
        return (ethCost, fee);
    }
}