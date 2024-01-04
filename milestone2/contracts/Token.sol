// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Token is IERC20, Ownable {
    uint256 private _totalSupply;
    uint256 private _tokenPrice;
    uint256 private _minTokenAmount;
    uint256 private _etherPool;
    uint256 private _feePool;
    uint256 private _feePercentage;
    uint256 private _lastFeeBurnDate = block.timestamp;
    uint256 private _buySellFeePercentage;
    uint256 private _leadingPrice;
    uint256 private _votingId;
    uint256 private _votingEndTime;
    uint256 private constant _timeToVote = 30 minutes;

    bool private _isVotingInProgress;

    struct Price {
        uint256 votingId;
        uint256 weight;
    }

    mapping(uint256 => Price) private _prices;
    mapping(address => uint256) private _voters;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    event VotingStarted(uint256 startTime, uint256 endTime);
    event Voted(address indexed voter, uint256 price, uint256 votes);
    event VotingEnded(uint256 endTime, uint256 price);
    event Burn(address indexed from, uint256 value);

    constructor(address initialOwner, uint256 initialTokenPrice, uint256 initialMinTokenAmount, uint256 initialFeePercentage) Ownable(initialOwner) {
        _tokenPrice = initialTokenPrice;
        _minTokenAmount = initialMinTokenAmount;
        _feePercentage = initialFeePercentage;
    }

    modifier onlyAfterVoting() {
        require(
            (_isVotingInProgress && (_voters[msg.sender] == _votingId)),
            "Cant perform operation while voting is active"
        );
        _;
    }

    modifier hasMinimumBalance(uint256 percentage) {
        require(
            _balances[msg.sender] >= ((_totalSupply * percentage) / 10_000),
            "Insufficient balance to execute this function"
        );
        _;
    }

    modifier validDestination(address to) {
        require(to != address(0x0));
        require(to != address(this));
        _;
    }

    // Token functions
    function _mint(address account, uint256 amount) private {
        _balances[account] += amount;
        _totalSupply += amount;

        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) private {
        require(_balances[account] >= amount, "Insufficient balance for burning");

        _balances[account] -= amount;
        _totalSupply -= amount;

        emit Burn(account, amount);
    }

    function burnFee() external onlyOwner {
        require((block.timestamp - 1 weeks) >= _lastFeeBurnDate);
        _feePool = 0;
    }

    // IERC20 Interface
    function totalSupply() external view returns(uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) external view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address to, uint256 amount) external override onlyAfterVoting validDestination(to) returns (bool) {
        require(_balances[msg.sender] >= amount, "Insufficient balance");

        _balances[msg.sender] -= amount;
        _balances[to] += amount;

        emit Transfer(msg.sender, to, amount);
        return true;
    }

    function allowance(address owner, address spender) external view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) external override returns (bool) {
        _allowances[msg.sender][spender] = amount;

        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) external override onlyAfterVoting validDestination(to) returns (bool) {
        require(_balances[from] >= amount, "Insufficient balance");
        require(_allowances[from][msg.sender] >= amount, "Insufficient allowance");

        _balances[from] -= amount;
        _balances[to] += amount;
        _allowances[from][msg.sender] -= amount;

        emit Transfer(from, to, amount);
        return true;
    }

    // Voting functions
    function startVoting(uint256 price) external hasMinimumBalance(1) {
        require(!_isVotingInProgress, "Voting already in progress");

        _votingId++;
        _isVotingInProgress = true;
        _votingEndTime = block.timestamp + _timeToVote;
        _prices[price] = Price({ votingId: _votingId, weight: _balances[msg.sender] });

        emit VotingStarted(block.timestamp, _votingEndTime);
    }

    function vote(uint256 price) external hasMinimumBalance(_minTokenAmount) {
        require(_isVotingInProgress, "Voting has not started yet");
        require(_voters[msg.sender] != _votingId, "Already voted");

        _voters[msg.sender] = _votingId;

        if (_prices[price].votingId == _votingId) {
            _prices[price].weight += _balances[msg.sender];
        } else {
            _prices[price] = Price({ votingId : _votingId, weight : _balances[msg.sender] });
        }

        if (_prices[price].weight >= _prices[_leadingPrice].weight) {
            _leadingPrice = price;
        }

        emit Voted(msg.sender, price, _balances[msg.sender]);
    }

    function endVoting() external onlyOwner {
        uint256 gasStart = gasleft();
        require(block.timestamp > _votingEndTime, "Voting period not ended yet");

        _tokenPrice = _leadingPrice;
        emit VotingEnded(block.timestamp, _leadingPrice);

        _leadingPrice = 0;

        uint256 gasUsed = gasStart - gasleft();
        address payable owner = payable(msg.sender);
        owner.transfer(gasUsed * tx.gasprice);
    }

    // Transactions functions
    function buy(uint256 amount) external payable onlyAfterVoting {
        (uint256 ethCost, uint256 fee) = _calculateCost(amount);
        uint256 totalCost = ethCost + fee;

        require(msg.value >= totalCost, "Insufficient funds sent");

        _mint(msg.sender, amount);
        _etherPool += ethCost;
        _feePool += fee;
    }

    function sell(uint256 amount) external payable onlyAfterVoting {
        require(_balances[msg.sender] >= amount, "Insufficient tokens");

        (uint256 ethCost, uint256 fee) = _calculateCost(amount);
        uint256 earned = ethCost - fee;

        _etherPool -= earned;

        _burn(msg.sender, amount);
        payable(msg.sender).transfer(earned);
    }

    function _calculateCost(uint256 tokenAmount) private view returns (uint256, uint256) {
        uint256 ethCost = tokenAmount * _tokenPrice;
        uint256 fee = (ethCost * _feePercentage) / 10_000;
        return (ethCost, fee);
    }
}
