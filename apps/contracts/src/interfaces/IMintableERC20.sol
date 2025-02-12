// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IMintableERC20 is IERC20 {
    error CanMintOnlyOncePerDay(uint256 lastMintedAt_, uint256 timeElapsed_);

    function mint() external;

    function _mint_(address account_, uint256 amount_) external;

    function _burn_(address account_, uint256 amount_) external;

    function _addMinterBurner(address account_) external;

    function _setAmmPool(address ammPool_) external;

    function ammPool() external view returns (address);

    function lastMintedTimestamp(address account_) external view returns (uint256);
}
