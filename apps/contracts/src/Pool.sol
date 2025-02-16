// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.20;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {SafeCast} from "@openzeppelin/contracts/utils/math/SafeCast.sol";
import {AggregatorV3Interface} from "@chainlink/interfaces/feeds/AggregatorV3Interface.sol";
import {RayMath} from "lib/RayMath.sol";
import {DEToken} from "./DEToken.sol";
import {DebtToken} from "./DebtToken.sol";
import {IPool} from "./interfaces/IPool.sol";
import {IDEToken} from "./interfaces/IDEToken.sol";
import {IDebtToken} from "./interfaces/IDebtToken.sol";
import {IController} from "./interfaces/IController.sol";

contract Pool is IPool, ReentrancyGuard, Ownable {
    using SafeERC20 for IERC20;
    using SafeCast for int256;

    IERC20 public token;
    IDEToken public deToken;
    IDebtToken public debtToken;
    IController public controller;

    uint256 public liquidityIndex;
    uint256 public interestRatePerSecond;
    uint256 public lastUpdateTimestamp;

    AggregatorV3Interface private _chainlinkPriceFeed;

    mapping(address => uint256) public unlockIntents;
    mapping(address => uint256) public unlocked;

    modifier onlyController() {
        if (msg.sender != address(controller)) {
            revert OnlyController();
        }

        _;
    }

    constructor(address token_, uint256 apy_, address controller_, address owner_) Ownable(owner_) {
        string memory deName = string.concat("deSync ", IERC20Metadata(token_).name());
        string memory deSymbol = string.concat("de", IERC20Metadata(token_).symbol());

        string memory debtName = string.concat(IERC20Metadata(token_).name(), " Debt");
        string memory debtSymbol = string.concat(IERC20Metadata(token_).symbol(), "debt");

        token = IERC20(token_);
        deToken = new DEToken(deName, deSymbol, address(this));
        debtToken = new DebtToken(debtName, debtSymbol, address(this));
        controller = IController(controller_);

        liquidityIndex = RayMath.RAY;
        interestRatePerSecond = apy_ / 365 days;
        lastUpdateTimestamp = block.timestamp;
    }

    function deposit(uint256 amount_) external override nonReentrant {
        token.safeTransferFrom(msg.sender, address(this), amount_);
        deToken.mint(msg.sender, amount_);
    }

    function unlock(uint256 amount_) external override nonReentrant {
        unlockIntents[msg.sender] += amount_;
        deToken.burn(msg.sender, amount_);

        emit UnlockIntentPosted(msg.sender, amount_, block.timestamp);
    }

    function _unlock(address account_, uint256 amount_) external override onlyOwner {
        if (unlockIntents[account_] < amount_) {
            revert InsufficientUnlockIntent(unlockIntents[account_], amount_);
        }

        unlocked[account_] += amount_;
        unlockIntents[account_] -= amount_;

        emit Unlocked(account_, amount_, block.timestamp);
    }

    function withdraw() external override nonReentrant {
        uint256 amount = unlocked[msg.sender];

        if (amount == 0) {
            revert NoAmountUnlocked();
        }

        unlocked[msg.sender] = 0;

        token.safeTransfer(msg.sender, amount);

        emit Withdrawn(msg.sender, amount, block.timestamp);
    }

    function _borrow(address account_, uint256 amount_) external override onlyController {
        debtToken.mint(account_, amount_);
        token.safeTransfer(account_, amount_);
    }

    function _liquidate(address account_, address receiver_) external override onlyController {
        uint256 debt = debtToken.balanceOf(account_);
        uint256 collateral = deToken.balanceOf(account_);

        token.safeTransferFrom(receiver_, address(this), collateral);
        deToken._poolTransfer(account_, receiver_, collateral);
        debtToken.burn(account_, debt);

        emit Liquidated(account_, receiver_, debt, block.timestamp);
    }

    function repay(address token_, uint256 amount_) external override {
        IERC20(token_).safeTransferFrom(msg.sender, address(this), amount_);
        debtToken.burn(msg.sender, amount_);

        emit Repaid(msg.sender, token_, amount_, block.timestamp);
    }

    function updateLiquidityIndex() external override {
        uint256 timeElapsed = block.timestamp - lastUpdateTimestamp;

        if (timeElapsed > 0) {
            liquidityIndex = liquidityIndex * (RayMath.RAY + interestRatePerSecond * timeElapsed) / RayMath.RAY;
            lastUpdateTimestamp = block.timestamp;
        }
    }

    function collateralOf(address account_) external view override returns (uint256) {
        return deToken.balanceOf(account_);
    }

    function collateralOfInUSD(address account_) external view override returns (uint256) {
        uint8 chainlinkDecimals = _chainlinkPriceFeed.decimals();
        uint8 tokenDecimals = IERC20Metadata(address(token)).decimals();

        (, int256 answer,,,) = _chainlinkPriceFeed.latestRoundData();

        uint256 b = deToken.balanceOf(account_);
        uint256 p = answer.toUint256();

        return (b * p * 1e18) / (10 ** (tokenDecimals + chainlinkDecimals));
    }

    function debtOf(address account_) external view override returns (uint256) {
        return debtToken.balanceOf(account_);
    }

    function debtOfInUSD(address account_) external view override returns (uint256) {
        uint8 chainlinkDecimals = _chainlinkPriceFeed.decimals();
        uint8 tokenDecimals = IERC20Metadata(address(token)).decimals();

        (, int256 answer,,,) = _chainlinkPriceFeed.latestRoundData();

        uint256 b = debtToken.balanceOf(account_);
        uint256 p = answer.toUint256();

        return (b * p * 1e18) / (10 ** (tokenDecimals + chainlinkDecimals));
    }

    function chainlinkPriceFeed() external view override returns (address) {
        return address(_chainlinkPriceFeed);
    }
}
