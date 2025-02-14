// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IDEToken is IERC20 {
    error OnlyPool();

    function mint(address account, uint256 amount) external;

    function burn(address account, uint256 amount) external;
}
