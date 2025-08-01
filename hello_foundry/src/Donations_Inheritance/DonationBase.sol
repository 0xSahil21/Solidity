// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DonationBase {
    address public owner;
    uint public totalDonated;
    string public causeName;

    mapping(address => uint) public donorBalances;

    constructor(string memory _causeName) {
        owner = msg.sender;
        causeName = _causeName;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    // Allows people to donate
    function donate() public payable {
        require(msg.value > 0, "Send some Ether");
        donorBalances[msg.sender] += msg.value;
        totalDonated += msg.value;
    }

    // Allow owner to withdraw the funds
    function withdraw() public onlyOwner {
        uint amount = address(this).balance;
        require(amount > 0, "Nothing to withdraw");

        (bool success, ) = payable(owner).call{value: amount}("");
        require(success, "Withdraw failed");
    }

    // View current contract balance
    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
}
