// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CryptoWallet {
    struct User {
        uint256 balance;
        uint256 totalDeposited;
        uint256 lastWithdrawTime;
    }

    mapping(address => User) public users;

    uint256 public dailyLimit = 10 ether;

    event Deposited(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event Transferred(address indexed from, address indexed to, uint256 amount);

    function deposit() public payable {
        require(msg.value > 0, "Amount must be greater than 0");

        users[msg.sender].balance += msg.value;
        users[msg.sender].totalDeposited += msg.value;

        emit Deposited(msg.sender, msg.value);
    }

    modifier withinDailyLimit(uint256 amount) {
        require(
            block.timestamp - users[msg.sender].lastWithdrawTime >= 1 days ||
                amount <= dailyLimit, //use and , store amount in a var
            "Daily limit exceeded"
        );
        _;
    }

    function withdraw(uint256 amount) public withinDailyLimit(amount) {
        require(amount > 0, "Amount must be greater than 0");
        require(users[msg.sender].balance >= amount, "Not enough balance");

        users[msg.sender].balance -= amount;
        users[msg.sender].lastWithdrawTime = block.timestamp;

        payable(msg.sender).transfer(amount);
        emit Withdrawn(msg.sender, amount);
    }

    function transfer(address to, uint256 amount) public {
        require(amount > 0, "Amount must be greater than 0");
        require(users[msg.sender].balance >= amount, "Not enough balance");

        users[msg.sender].balance -= amount;
        users[to].balance += amount;

        emit Transferred(msg.sender, to, amount);
    }

    function getBalance(address user) public view returns (uint256) {
        return users[user].balance;
    }

    function getTotalDeposited(address user) public view returns (uint256) {
        return users[user].totalDeposited;
    }

    receive() external payable {
        users[msg.sender].balance += msg.value;
        users[msg.sender].totalDeposited += msg.value;
        emit Deposited(msg.sender, msg.value);
    }

    fallback() external payable {
        users[msg.sender].balance += msg.value;
        users[msg.sender].totalDeposited += msg.value;
        emit Deposited(msg.sender, msg.value);
    }
}
