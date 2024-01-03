pragma solidity ^0.8.19;

import "./MyToken.sol";

contract Transactions is MyToken {
    event TokensSold(address indexed seller, uint256 amount);

    function buy(uint256 _tokenAmount) external payable onlyAfterVoting {
        (uint256 ethCost, uint256 fee) = calculateCost(_tokenAmount);
        uint256 cost = ethCost.add(fee);

        require(msg.value >= cost, "Insufficient funds sent");

        transfer(msg.sender, _tokenAmount);
        etherPool = etherPool.add(cost);
    }

    function sell(uint256 _tokenAmount) external payable onlyAfterVoting {
        require(balances[msg.sender] >= _tokenAmount, "Insufficient tokens");

        (uint256 ethCost, uint256 fee) = calculateCost(_tokenAmount);

        uint256 cost = ethCost.add(fee);
        uint256 earned = ethCost.sub(fee);

        etherPool = etherPool.sub(cost);
        balances[msg.sender] -= _tokenAmount;

        payable(msg.sender).transfer(earned);

        emit TokensSold(msg.sender, _tokenAmount);
    }

    function calculateCost(uint256 _tokenAmount) external returns (uint256, uint256) {
        uint256 ethCost = _tokenAmount.mul(tokenPrice);
        uint256 fee = ethCost.mul(feePercentage).div(100);
        return (ethCost, fee);
    }

    function burnFee() external onlyOwner {
        require((block.timestamp + 1 weeks) > lastFeeBurnDate, "Last fee burn was less then  1 week ago");
        etherPool = 0;
    }
}
