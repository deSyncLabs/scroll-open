// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IDebtToken is IERC20 {
    error OnlyPool();

    error NotAllowed();

    function initialize(string memory name_, string memory symbol_, address pool_) external;

    function deTransferFrom(address from, address to, uint256 amount) external;

    function mint(address account, uint256 amount) external;

    function burn(address account, uint256 amount) external;
}
