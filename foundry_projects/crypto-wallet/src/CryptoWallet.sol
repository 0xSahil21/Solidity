// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

//Class : 23/7

contract CryptoWallet {

  address public owner;

  mapping(address => uint256) public balances;

  event Deposit(address indexed sender, uint256 amount);
  event Withdraw(address indexed recepient, uint256 amount);
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

//sets the owner
  constructor() {
    owner = msg.sender;
  }

  modifier onlyOwner() {
    require(msg.sender == owner, "Not the contract owner");
    _;
  }

  function deposit() public payable {
    require(msg.value > 0, "Deposit amount must be greater than zero");
    
    balances[msg.sender] += msg.value;
    
    emit Deposit(msg.sender, msg.value);
  }

  function withdraw(uint256 amount) public {
    require( amount > 0, "Withdrawal amount must be greater than zero");
    
    require(balances[msg.sender] >= amount, "Insufficient balance");
    
    balances[msg.sender] -= amount;

    //payable(msg.sender).transfer(amount);
    (bool success, ) = payable(msg.sender).call{value: amount}("");
    require(success, "Withdrawal failed");
    
    emit Withdraw(msg.sender, amount);
  }

  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0), "New owner is the zero address");
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

  function getBalance() public view returns (uint256) {
    return balances[msg.sender];
  } 

  function getUserBalance(address _account) public view returns (uint256) {
    return balances[_account];
  }
 

}