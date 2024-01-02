pragma solidity ^0.8.0;

import "./Token.sol";

contract Interface is Token {
    function totalSupply() external view returns(uint256) {
        return totalSupply;
    }

    function balanceOf(address account) external view returns (uint256) {
        return addressToBalance[account];
    }

    function transfer(address to, uint256 value) external onlyAfterVoting returns (bool) {
        require(addressToBalance[msg.sender] >= value, "Insufficient funds on the account");

        addressToBalance[msg.sender] = addressToBalance[msg.sender].sub(value);
        addressToBalance[to] = addressToBalance[to].add(value);

        emit Transfer(msg.sender, to, value);
        return true;
    }

    function allowance(address owner, address spender) external view returns (uint256) {
        return addressAllowance[owner][spender];
    }

    function approve(address spender, uint256 value) external returns (bool) {
        addressAllowance[mgs.sender][spender] = value;

        emit Approval(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) external returns (bool) {
        require(addressAllowance[from][msg.sender] >= value, "Insufficient funds on the account");

        addressToBalance[to] = addressToBalance[to].add(value);
        addressToBalance[from] = addressToBalance[from].sub(value);
        addressAllowance[from][msg.sender] = addressAllowance[from][msg.sender].sub(value);

        emit Transfer(from, to, value);
        return true;
    }
}
