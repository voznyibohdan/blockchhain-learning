pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MyToken is IERC20, Ownable, SafeMath {
    using SafeMath for uint256;

    uint256 internal totalSupply;
    uint256 internal tokenPrice;
    uint256 internal minTokenAmount;
    uint256 internal etherPool;
    uint256 internal lastFeeBurnDate;
    uint256 internal feePercentage;

    address[] internal votersList;
    bool internal isVotingInProgress = false;

    mapping(address => uint256) internal balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    constructor(uint256 initialTotalSupply, uint256 initialTokenPrice, uint256 initialMinTokenAmount, uint256 initialFeePercentage) {
        totalSupply = initialTotalSupply;
        tokenPrice = initialTokenPrice;
        minTokenAmount = initialMinTokenAmount;
        feePercentage = initialFeePercentage;
    }

    modifier onlyAfterVoting() {
        require((isVotingInProgress && votersList[msg.sender]), "Cant perform operation while voting is active");
        _;
    }

    function _setFeePercentage(uint256 percentage) private onlyOwner {
        feePercentage = percentage;
    }

    // IERC20 Interface
    function totalSupply() external view returns(uint256) {
        return totalSupply;
    }

    function balanceOf(address account) external view override returns (uint256) {
        return balances[account];
    }

    function transfer(address to, uint256 amount) external override onlyAfterVoting returns (bool) {
        require(balances[msg.sender] >= amount, "Insufficient balance");

        balances[msg.sender] = balances[msg.sender].sub(amount);
        balances[to] = balances[to].add(amount);

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

    function transferFrom(address from, address to, uint256 amount) external override onlyAfterVoting returns (bool) {
        require(balances[from] >= amount, "Insufficient balance");
        require(_allowances[from][msg.sender] >= amount, "Insufficient allowance");

        balances[from] = balances[from].sub(amount);
        balances[to] = balances[to].add(amount);
        _allowances[from][msg.sender] = _allowances[from][msg.sender].sub(amount);

        emit Transfer(from, to, amount);
        return true;
    }
}
