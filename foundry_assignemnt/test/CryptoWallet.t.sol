// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/CryptoWallet.sol";

contract CryptoWalletTest is Test {
    CryptoWallet wallet;
    address user1;
    address user2;

    function setUp() public {
        wallet = new CryptoWallet();
        user1 = address(0x1);
        user2 = address(0x2);

        vm.deal(user1, 10 ether);
        vm.deal(user2, 10 ether);
    }

    
    function testDeposit() public {
        vm.prank(user1);
        wallet.deposit{value: 2 ether}();
        assertEq(wallet.getBalance(user1), 2 ether);
    }

    function test_RevertWhen_DepositZeroETH() public {
        vm.prank(user1);
        vm.expectRevert(bytes("Must send some ETH"));
        wallet.deposit{value: 0 ether}();
    }

    
    //@todo check and fix why this test is failing
    function testWithdraw() public {
        vm.prank(user1);
        wallet.deposit{value: 2 ether}();

        vm.prank(user1);
        wallet.withdraw(1 ether);
        assertEq(wallet.getBalance(user1), 1 ether);
    }

    function test_RevertWhen_WithdrawMoreThanBalance() public {
        vm.prank(user1);
        wallet.deposit{value: 1 ether}();

        vm.prank(user1);
        vm.expectRevert(
            abi.encodeWithSelector(
                CryptoWallet.InsufficientBalance.selector,
                2 ether,
                1 ether
            )
        );
        wallet.withdraw(2 ether);
    }

    function test_RevertWhen_WithdrawExceedsDailyLimit() public {
        vm.prank(user1);
        wallet.deposit{value: 3 ether}();

        vm.prank(user1);
        wallet.withdraw(2 ether);

        vm.prank(user1);
        vm.expectRevert(
            abi.encodeWithSelector(
                CryptoWallet.ExceedsDailyLimit.selector,
                3 ether,
                2 ether
            )
        );
        wallet.withdraw(1 ether);
    }

    function testDailyLimitResetsAfter24Hours() public {
        vm.prank(user1);
        wallet.deposit{value: 3 ether}();

        vm.prank(user1);
        wallet.withdraw(2 ether);

        vm.warp(block.timestamp + 1 days + 1);

        vm.prank(user1);
        wallet.withdraw(1 ether);
        assertEq(wallet.getBalance(user1), 0 ether);
    }

    
    function testTransfer() public {
        vm.prank(user1);
        wallet.deposit{value: 2 ether}();

        vm.prank(user1);
        wallet.transfer(user2, 1 ether);

        assertEq(wallet.getBalance(user1), 1 ether);
        assertEq(wallet.getBalance(user2), 1 ether);
    }

    function test_RevertWhen_TransferToZeroAddress() public {
        vm.prank(user1);
        wallet.deposit{value: 1 ether}();

        vm.prank(user1);
        vm.expectRevert(bytes("Cannot send to zero address"));
        wallet.transfer(address(0), 0.5 ether);
    }

    function test_RevertWhen_TransferMoreThanBalance() public {
        vm.prank(user1);
        wallet.deposit{value: 1 ether}();

        vm.prank(user1);
        vm.expectRevert(
            abi.encodeWithSelector(
                CryptoWallet.InsufficientBalance.selector,
                2 ether,
                1 ether
            )
        );
        wallet.transfer(user2, 2 ether);
    }

    
    function testReceiveFunction() public {
        vm.prank(user1);
        (bool success, ) = address(wallet).call{value: 1 ether}("");
        assertTrue(success);
        assertEq(wallet.getBalance(user1), 1 ether);
    }

    function testFallbackFunction() public {
        vm.prank(user1);
        (bool success, ) = address(wallet).call{value: 1 ether}(abi.encodeWithSignature("nonExistentFunction()"));
        assertTrue(success);
        assertEq(wallet.getBalance(user1), 1 ether);
    }
}
