// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

contract Token {
    uint256 public totalSupply;
    string public name;
    mapping(address => uint256) balance;
    mapping(address => mapping(address => uint256)) allowance;
    address public owner;

    constructor() {
        owner = msg.sender;
        totalSupply = 1000;
        name = "Token";
        balance[msg.sender] = totalSupply;
    }

    function balanceOf(address _user) public view returns (uint256) {
        return balance[_user];
    }

    function transfer(address _to, uint256 _amount) public returns (bool) {
        require(_to != address(0));
        require(balance[msg.sender] >= _amount, "not sufficient balance");
        balance[msg.sender] -= _amount;
        balance[_to] += _amount;
        return true;
    }

    function approve(address _spender, uint256 _amount) public returns (bool) {
        require(_spender != address(0));
        allowance[msg.sender][_spender] = _amount;
        return true;
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _amount
    ) public returns (bool) {
        require(
            allowance[_from][msg.sender] >= _amount,
            "Insufficient Allowance"
        );
        balance[_from] -= _amount;
        balance[_to] += _amount;
        allowance[_from][msg.sender] -= _amount;
        return true;
    }
}
