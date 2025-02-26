// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract MockAggregatorV3 is Ownable {
    int256 private _price;
    uint8 private _decimals;

    constructor(int256 price_, uint8 decimals_, address owner_) Ownable(owner_) {
        _price = price_;
        _decimals = decimals_;
    }

    function latestRoundData() external view returns (uint80, int256, uint256, uint256, uint80) {
        return (0, _price, 0, 0, 0);
    }

    function decimals() external view returns (uint8) {
        return _decimals;
    }

    function setPrice(int256 price_) external onlyOwner {
        _price = price_;
    }
}
