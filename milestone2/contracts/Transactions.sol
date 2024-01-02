pragma solidity ^0.8.0;

import "./Token.sol";

contract Transactions is Token {
    event TokensSold(address indexed seller, uint256 amount);

    function buy(uint256 _tokenAmount) external payable onlyAfterVoting {
        (uint256 ethCost, uint256 fee) = calculateCost(_tokenAmount);
        uint256 cost = ethCost.add(fee);

        require(msg.value >= cost, "Insufficient funds sent");

        transfer(msg.sender, _tokenAmount);
        etherPool += cost;
    }

    function sell(uint256 _tokenAmount) external payable onlyAfterVoting {
        require(addressToBalance[msg.sender] >= _tokenAmount, "Insufficient tokens");

        (uint256 ethCost, uint256 fee) = calculateCost(_tokenAmount);

        uint256 cost = ethCost.add(fee);
        uint256 earned = ethCost.sub(fee);

        etherPool -= cost;
        addressToBalance[msg.sender] -= _tokenAmount;

        payable(msg.sender).transfer(earned);

        emit TokensSold(msg.sender, _tokenAmount);
    }

    function calculateCost(uint256 _tokenAmount) external returns (uint256, uint256) {
        uint256 ethCost = _tokenAmount.mul(tokenPrice);
        uint256 fee = ethCost.mul(feePercentage).div(100);
        return (ethCost, fee);
    }
}
