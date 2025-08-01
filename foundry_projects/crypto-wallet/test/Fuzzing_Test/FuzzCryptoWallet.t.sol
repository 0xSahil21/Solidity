// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import {CryptoWallet} from "../../src/CryptoWallet.sol"; 

contract FuzzCryptoWallet is Test {

  CryptoWallet wallet;

  address user = address(0x123);
  address owner = address(0x456);

  function setUp() public {
    wallet = new CryptoWallet(); // Deploying the CryptoWallet contract, this initializes 'wallet' so that we can test its functions.
  }

  function test_InitOwner() public view {
    assertEq(wallet.owner(), address(this), "The owner should be the address that deployed the contract.init owner failed");
  }

  function test_FuzzDeposit(uint256 amount) public {
    vm.assume(amount > 0 && amount < 1 ether); // Ensure the amount is a valid deposit

    vm.deal(user, amount);

    vm.startPrank(user); // to simulate user actions

    wallet.deposit{value: amount}();  //fuzzing occurs here, the green arrow indicates the fuzzing input 

    assertEq(wallet.getUserBalance(user), amount, "User's balance should match the deposit amount");

    vm.stopPrank();
  } 

//task
  function test_FuzzWithdraw(uint256 _amount) public {
    vm.assume(_amount > 0 && _amount < 1 ether);

    vm.deal(user, 1 ether); 

    vm.startPrank(user); 

    wallet.deposit{value: _amount}();

    assertEq(wallet.getBalance(), _amount, "Users balance and deposit amount must match to be able to withdraw");

    wallet.withdraw(_amount); 

    assertEq(wallet.getBalance(), 0, "User's balance should be zero after withdrawal");

    vm.stopPrank();
  } 


}