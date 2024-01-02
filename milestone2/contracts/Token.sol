pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract Token is Ownable, IERC20  {
    using SafeMath for uint256;

    mapping(address => uint256) public addressToBalance;
    mapping(address => mapping(address => uint256)) public addressAllowance;

    uint256 public totalSupply;
    uint256 public tokenPrice;
    uint256 public timeToVote;
    uint256 public feePercentage;
    uint256 public etherPool;

    bool internal votingIsInProgress;

    constructor(uint256 initialSupply, uint256 initialTimeToVote, uint tokenPrice) {
        totalSupply = initialSupply;
        timeToVote = initialTimeToVote;
        tokenPrice = tokenPrice;
    }

    modifier onlyAfterVoting() {
        require(voters[msg.sender], "Cant perform operation while voting is active");
        _;
    }

    function _setFeePrice(uint256 newFeePercentage) private onlyOwner {
        feePercentage = newFeePercentage;
    }
}
