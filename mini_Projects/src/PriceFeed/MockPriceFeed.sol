// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IPriceFeed.sol";

contract MockPriceFeed is IPriceFeed {
    int256 private ethInrPrice = 245000;
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    function getLatestPrice() external view override returns (int256) {
        return ethInrPrice;
    }

    // 🔹 Bonus: Owner-only price update function
    function updatePrice(int256 newPrice) external onlyOwner {
        ethInrPrice = newPrice;
    }
}
