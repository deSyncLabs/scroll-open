// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.20;

import {IPool} from "./IPool.sol";

interface IStratergyPool is IPool {
    function initialize(
        address token0_,
        address controller_,
        address owner_,
        address token1_,
        uint24 poolFee_,
        address nonfungiblePositionManager_,
        address swapRouter_,
        address futuresMarket_,
        address priceFeed_
    ) external;
}
