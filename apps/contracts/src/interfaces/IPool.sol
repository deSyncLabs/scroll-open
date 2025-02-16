// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IDEToken} from "./IDEToken.sol";
import {IDebtToken} from "./IDebtToken.sol";
import {IController} from "./IController.sol";

interface IPool {
    error OnlyDEToken();

    error OnlyController();

    event UnlockIntentPosted(address indexed account, uint256 indexed amount, uint256 timestamp);

    event Deposit(address indexed account, uint256 indexed amount, uint256 timestamp);

    event Withdrawn(address indexed account, uint256 indexed amount, uint256 timestamp);

    event Borrowed(address indexed account, uint256 indexed amount, uint256 timestamp);

    event Liquidated(address indexed account, address indexed receiver, uint256 indexed amount, uint256 timestamp);

    event Repaid(address indexed account, address indexed token, uint256 indexed amount, uint256 timestamp);

    function deposit(uint256 amount) external;

    function unlock(uint256 amount) external;

    function withdraw() external;

    function _borrow(address account_, uint256 amount) external;

    function _liquidate(address account_, address receiver_) external;

    function repay(address token_, uint256 amount_) external;

    function updateLiquidityIndex() external;

    function liquidityIndex() external view returns (uint256);

    function interestRatePerSecond() external view returns (uint256);

    function lastUpdateTimestamp() external view returns (uint256);

    function token() external view returns (IERC20);

    function deToken() external view returns (IDEToken);

    function debtToken() external view returns (IDebtToken);

    function controller() external view returns (IController);

    function unlocked(address account) external view returns (uint256);

    function collateralOf(address account) external view returns (uint256);

    function collateralOfInUSD(address account) external view returns (uint256);

    function debtOf(address account) external view returns (uint256);

    function debtOfInUSD(address account) external view returns (uint256);

    function chainlinkPriceFeed() external view returns (address);
}
