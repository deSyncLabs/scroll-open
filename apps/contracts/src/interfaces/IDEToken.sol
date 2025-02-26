// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

interface IDEToken is IERC20, IERC20Metadata {
    error OnlyExternalOwner();

    error DebtExists(uint256 amountInUSD_);

    function mint(address account, uint256 amount) external;

    function burn(address account, uint256 amount) external;

    function _poolTransfer(address from, address to, uint256 amount) external;

    function updateYieldDaily() external;

    function externalOwner() external view returns (address);
}
