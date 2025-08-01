// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SimpleWallet {
    address public owner;

    constructor() {
        owner = msg.sender; // Set the wallet owner to the address that deploys the contract
    }

    // Allow anyone to deposit Ether into the wallet
    function deposit() public payable {}

    // Allow the owner to withdraw a specific amount
    function withdraw(uint amount) public {
        require(msg.sender == owner, "Only owner can withdraw");
        require(address(this).balance >= amount, "Not enough balance");

        payable(owner).transfer(amount);
    }

    // Check wallet balance
    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
}
