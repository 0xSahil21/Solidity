// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IPriceFeed.sol";

contract PriceConsumer {
    address public oracleAddress;
    address public owner;
    IPriceFeed public priceFeed;

    error ZeroPriceReturned(); // 🔹 Custom error

    constructor(address _oracleAddress) {
        owner = msg.sender;
        oracleAddress = _oracleAddress;
        priceFeed = IPriceFeed(_oracleAddress);
    }

    function getEthInrPrice() public view returns (int256) {
        int256 price = priceFeed.getLatestPrice();

        if (price == 0) {
            revert ZeroPriceReturned(); // 🔹 Revert using custom error
        }

        return price;
    }

    function updateOracle(address newOracle) public {
        require(msg.sender == owner, "Only owner can update oracle");
        oracleAddress = newOracle;
        priceFeed = IPriceFeed(newOracle);
    }// no need of this func, its a bug
}
