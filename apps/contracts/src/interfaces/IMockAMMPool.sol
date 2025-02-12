// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IMintableERC20} from "./IMintableERC20.sol";

interface IMockAMMPool {
    error CannotUpdateInterestRatePerSecond();

    error OnlyPool();

    function deposit(uint256 amount_) external;

    function withdraw(uint256 amount_) external;

    function updateInterestRatePerSecond(uint256 interestRatePerSecond_) external;

    function interestRatePerSecond() external view returns (uint256);

    function token() external view returns (IMintableERC20);

    function balance() external view returns (uint256);
}
