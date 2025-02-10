// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IPool {
    error OnlyDEToken();

    event UnlockIntentPosted(address indexed account, uint256 indexed amount, uint256 timestamp);

    event Withdrawn(address indexed account, uint256 indexed amount, uint256 timestamp);


    function deposit(uint256 amount) external;

    function unlock(uint256 amount) external;

    function withdraw() external;

    function updateLiquidityIndex() external;

    function liquidityIndex() external view returns (uint256);

    function interestRatePerSecond() external view returns (uint256);

    function lastUpdateTimestamp() external view returns (uint256);
}
