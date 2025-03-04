// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

interface IDEToken is IERC20, IERC20Metadata {
    error OnlyExternalOwner();

    error DebtExists(uint256 amountInUSD_);

    error NoInterestEarned();

    function initialize() external;

    function update(address account_) external;

    function mint(address account_, uint256 amount_) external;

    function burn(address account_, uint256 amount_) external;

    function _poolTransfer(address from_, address to_, uint256 amount_) external;

    function externalOwner() external view returns (address);

    function lastActionTimestamp(address account_) external view returns (uint256);
}
