// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

contract Storage {
    uint256 public tokenTotalSupply;
    uint256 public tokenPrice;
    uint256 public minTokenAmount;
    uint256 public etherPool;
    uint256 public feePool;
    uint256 public feePercentage;
    uint256 public lastFeeBurnDate = block.timestamp;
    uint256 public buySellFeePercentage;
    uint256 public leadingPrice;
    uint256 public votingId;
    uint256 public votingEndTime;
    uint256 public constant timeToVote = 30 minutes;

    bool public isVotingInProgress;

    struct Price {
        uint256 votingId;
        uint256 weight;
    }

    mapping(uint256 => Price) public prices;
    mapping(address => uint256) public voters;
    mapping(address => uint256) public balances;
    mapping(address => mapping(address => uint256)) public allowances;

    constructor(address initialOwner, uint256 initialTokenPrice, uint256 initialMinTokenAmount, uint256 initialFeePercentage) {
        tokenPrice = initialTokenPrice;
        minTokenAmount = initialMinTokenAmount;
        feePercentage = initialFeePercentage;
    }
}
