// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title CryptoWallet – A secure ETH wallet with daily withdrawal limit
/// @author Karan Bharda (scarcemrk)
/// @notice This contract enables deposits, withdrawals, and ETH transfers with per-user daily limits

contract CryptoWallet {
    /// @dev Tracks ETH balance of each user
    mapping(address => uint256) public balances;

    /// @dev Tracks total ETH deposited and daily withdrawal tracking per user
    struct User {
        uint256 totalDeposited;
        uint256 lastWithdrawTime;
        uint256 withdrawnToday;
    }

    mapping(address => User) public userInfo;

    address public owner;
    uint256 public constant DAILY_WITHDRAW_LIMIT = 2 ether;

    /// @dev Events for logging actions
    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);
    event Transfer(address indexed from, address indexed to, uint256 amount);

    /// @dev Custom errors for gas efficiency
    error InsufficientBalance(uint256 requested, uint256 available);
    error ExceedsDailyLimit(uint256 requested, uint256 limit);

    constructor() {
        owner = msg.sender;
    }

    /// @notice Modifier to enforce time-based daily withdrawal limit
    modifier withinDailyLimit(uint256 _amount) {
        User storage user = userInfo[msg.sender];

        // Reset daily withdrawal if more than 24h passed
        if (block.timestamp > user.lastWithdrawTime + 1 days) {
            user.withdrawnToday = 0;
            user.lastWithdrawTime = block.timestamp;
        }

        if (user.withdrawnToday + _amount > DAILY_WITHDRAW_LIMIT) {
            revert ExceedsDailyLimit(
                user.withdrawnToday + _amount,
                DAILY_WITHDRAW_LIMIT
            );
        }

        _;
    }

    /// @notice Deposit ETH to the contract
    function deposit() public payable {
        require(msg.value > 0, "Must send some ETH");

        balances[msg.sender] += msg.value;
        userInfo[msg.sender].totalDeposited += msg.value;

        emit Deposit(msg.sender, msg.value);
    }

    /// @notice Withdraw ETH with per-user daily limit
    function withdraw(uint256 _amount) public withinDailyLimit(_amount) {
        if (_amount > balances[msg.sender]) {
            revert InsufficientBalance(_amount, balances[msg.sender]);
        }

        balances[msg.sender] -= _amount;
        userInfo[msg.sender].withdrawnToday += _amount;

        payable(msg.sender).transfer(_amount);

        emit Withdraw(msg.sender, _amount);
    }

    /// @notice Transfer ETH to another user's balance within the contract
    function transfer(address _to, uint256 _amount) public {
        require(_to != address(0), "Cannot send to zero address");

        if (_amount > balances[msg.sender]) {
            revert InsufficientBalance(_amount, balances[msg.sender]);
        }

        balances[msg.sender] -= _amount;
        balances[_to] += _amount;

        emit Transfer(msg.sender, _to, _amount);
    }

    /// @notice View balance of a specific user
    function getBalance(address _user) public view returns (uint256) {
        return balances[_user];
    }

    /// @notice Accept direct ETH transfers
    receive() external payable {
        deposit();
    }

    /// @notice Fallback function for non-matching calls
    fallback() external payable {
        deposit();
    }
}
