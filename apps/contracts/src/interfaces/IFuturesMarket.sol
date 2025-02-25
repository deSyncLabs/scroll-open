// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IFuturesMarket {
    function openPosition(address token0_, address token1_, uint256 amount0_, bool isLong_)
        external
        returns (uint256);

    function closePosition(uint256 positionId_) external returns (bool, uint256);
}
