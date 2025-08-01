// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import {CryptoWallet} from "../src/CryptoWallet.sol"; 

contract CryptoWalletTest is Test {

  CryptoWallet wallet;

  address user = address(0x123); 

  function setUp() public {
    wallet = new CryptoWallet(); // Deploying the CryptoWallet contract, this initializes 'wallet' so that we can test its functions.

    vm.deal(user, 1 ether); // Giving user some ether for testing
  }

  function testInitialOwner() public view {
    assertEq(wallet.owner(), address(this), "The owner should be the address that deployed the contract.init owner failed");
  }
   
  function testDeposit() public {
    vm.startPrank(user); // to simulate user actions

    wallet.deposit{value: 0.5 ether}(); 

    assertEq(wallet.getBalance() , 0.5 ether, "User's balance should be 0.5 ether after deposit");

    assertEq(wallet.getUserBalance(user), 0.5 ether, "User's balance should be 0.5 ether after deposit");

    //@follow-up
    //assertEq(wallet.totalBalance(), 0.5 ether, "Total balance should be 0.5 ether after deposit"); //total bal to be defined

    vm.stopPrank();
  }

  function test_Withdraw() public {
    vm.deal(user, 1 ether); // Ensure user has enough ether to withdraw
    vm.startPrank(user); // to simulate user actions

    wallet.deposit{value: 0.5 ether}(); // firstly user has to deposit to withdraw, thus deposits 0.5 ether   

    assertEq(wallet.getBalance(), 0.5 ether, "User's balance should be 0.5 ether before withdrawal");

    wallet.withdraw(0.5 ether); // User withdraws 0.5 ether

    assertEq(wallet.getBalance(), 0 ether, "User's balance should be 0 ether after withdrawal");

  }

  function test_Insuff_Withdrawal() public {
    vm.startPrank(user); 

    wallet.deposit{value: 0.5 ether}(); 

    vm.expectRevert("Insufficient balance");
    wallet.withdraw(1 ether); // Attempting to withdraw more than the balance should revert

    vm.stopPrank();
  }

  function test_Zero_Withdrawal() public {
    vm.startPrank(user); 

    wallet.deposit{value: 0.5 ether}(); 

    vm.expectRevert("Withdrawal amount must be greater than zero");
    wallet.withdraw(0); // Attempting to withdraw zero should revert

    vm.stopPrank();
  }

  // function test_Negative_Withdrawal() public {
  //   vm.startPrank(user); 

  //   wallet.deposit{value: 0.5 ether}(); 

  //   vm.expectRevert("Withdrawal amount must be greater than zero");
  //   wallet.withdraw(-1 ether); // Attempting to withdraw a negative amount should revert

  //   vm.stopPrank();
  // }

//above function gives error as Solidity does not support negative values for uint256, so this test is not applicable. So if needed we can test for negative values in a different way, like using int256.

  function test_Ownership_Transfer() public {
    address newOwner = address(0x456);

    vm.startPrank(wallet.owner()); // Simulate the current owner transferring ownership

    wallet.transferOwnership(newOwner); // Transfer ownership to new owner

    assertEq(wallet.owner(), newOwner, "Ownership should be transferred to the new owner");

    vm.stopPrank();
  }

  function test_Ownership_Transfer_To_ZeroAddress() public {
    vm.startPrank(wallet.owner());

    vm.expectRevert();
    wallet.transferOwnership(address(0)); // Attempting to transfer ownership to zero address should revert

    vm.stopPrank();
  }

  function test_GetUserBalance() public {
    vm.startPrank(user); 

    wallet.deposit{value: 0.5 ether}(); 

    uint256 userBalance = wallet.getUserBalance(user);

    assertEq(userBalance, 0.5 ether, "getUserBalance should return the correct balance for the user");

    vm.stopPrank();
  }

  function test_GetBalance() public {
    vm.startPrank(user); 

    wallet.deposit{value: 0.5 ether}(); 

    uint256 balance = wallet.getBalance();

    assertEq(balance, 0.5 ether, "getBalance should return the correct balance for the user");

    vm.stopPrank();
  }

  function test_Deposit_Zero_Amount() public {
    vm.startPrank(user); 

    vm.expectRevert("Deposit amount must be greater than zero");
    wallet.deposit{value: 0}(); // Attempting to deposit zero should revert

    vm.stopPrank();
  }

  function test_TransferOwnership_NotOwner() public {
    address newOwner = address(0x456);

    vm.startPrank(user); // Simulate a user trying to transfer ownership 

    vm.expectRevert("Not the contract owner");
    wallet.transferOwnership(newOwner); // Non-owner should not be able to transfer ownership

    vm.stopPrank();
  }
}