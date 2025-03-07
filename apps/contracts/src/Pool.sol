// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.20;

import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {ReentrancyGuardUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {SafeCast} from "@openzeppelin/contracts/utils/math/SafeCast.sol";
import {Clones} from "@openzeppelin/contracts/proxy/Clones.sol";
import {AggregatorV3Interface} from "@chainlink/interfaces/feeds/AggregatorV3Interface.sol";
import {RayMath} from "lib/RayMath.sol";
import {IPool} from "./interfaces/IPool.sol";
import {IDEToken} from "./interfaces/IDEToken.sol";
import {IDebtToken} from "./interfaces/IDebtToken.sol";
import {IController} from "./interfaces/IController.sol";

abstract contract Pool is IPool, ReentrancyGuardUpgradeable, OwnableUpgradeable {
    using SafeERC20 for IERC20;
    using SafeCast for int256;
    using Clones for address;

    address public immutable deTokenImplementation;
    address public immutable debtTokenImplementation;

    IERC20 public token;
    IDEToken public deToken;
    IDebtToken public debtToken;
    IController public controller;

    uint256 private _apy;
    uint256 public interestRatePerSecond;
    uint256 public lastUpdateTimestamp;

    uint256 internal _beforeExecutionToken0Balance;
    uint256 internal _afterExecutionToken0Balance;

    mapping(address user_ => uint256) private _lastDeposited;

    AggregatorV3Interface private _chainlinkPriceFeed;

    mapping(address => uint256) public unlockIntents;
    mapping(address => uint256) public unlockIntentTimings;
    mapping(address => uint256) public borrowIntents;
    mapping(address => uint256) public borrowIntentTimings;

    bool public locked;
    uint256 private _totalUnlockedIntents;
    uint256 internal _totalUnlocked;

    modifier onlyController() {
        if (msg.sender != address(controller)) {
            revert OnlyController();
        }

        _;
    }

    modifier tryWithdrawing(address account_) {
        if (unlockIntents[account_] > 0) {
            if (unlockIntentTimings[account_] <= lastUpdateTimestamp) {
                token.safeTransfer(account_, unlockIntents[account_]);
                unlockIntents[account_] = 0;
                _totalUnlocked -= unlockIntents[account_];
            }
        }

        _;
    }

    modifier tryBorrowing(address account_) {
        if (borrowIntents[account_] > 0) {
            if (borrowIntentTimings[account_] <= lastUpdateTimestamp) {
                debtToken.mint(account_, borrowIntents[account_]);
                token.safeTransfer(account_, borrowIntents[account_]);
                borrowIntents[account_] = 0;
                _totalUnlocked -= borrowIntents[account_];
            }
        }

        _;
    }

    // in memory of the old constructor
    // constructor(address token_, address controller_, address priceFeed_, address owner_) Ownable(owner_) {
    //     string memory deName = string.concat("deSync ", IERC20Metadata(token_).name());
    //     string memory deSymbol = string.concat("de", IERC20Metadata(token_).symbol());

    //     string memory debtName = string.concat(IERC20Metadata(token_).name(), " Debt");
    //     string memory debtSymbol = string.concat(IERC20Metadata(token_).symbol(), "debt");

    //     token = IERC20(token_);
    //     deToken = new DEToken(deName, deSymbol, address(this), address(this), owner_);
    //     debtToken = new DebtToken(debtName, debtSymbol, address(this));
    //     controller = IController(controller_);

    //     _chainlinkPriceFeed = AggregatorV3Interface(priceFeed_);

    //     _apy = 0;
    //     interestRatePerSecond = 0;
    //     lastUpdateTimestamp = block.timestamp;

    //     _totalUnlockedIntents = 0;
    //     _totalUnlocked = 0;
    //     locked = false;
    // }

    constructor(address deTokenImplementation_, address debtTokenImplementation_) {
        if (deTokenImplementation_ == address(0) || debtTokenImplementation_ == address(0)) {
            revert ZeroAddress();
        }

        deTokenImplementation = deTokenImplementation_;
        debtTokenImplementation = debtTokenImplementation_;
    }

    function initialize(address token_, address controller_, address priceFeed_, address owner_) internal {
        __Ownable_init(owner_);
        __ReentrancyGuard_init();

        string memory deName = string.concat("deSync ", IERC20Metadata(token_).name());
        string memory deSymbol = string.concat("de", IERC20Metadata(token_).symbol());

        string memory debtName = string.concat(IERC20Metadata(token_).name(), " Debt");
        string memory debtSymbol = string.concat(IERC20Metadata(token_).symbol(), "debt");

        deToken = IDEToken(deTokenImplementation.clone());
        deToken.initialize(deName, deSymbol, address(this), address(this), owner_);

        debtToken = IDebtToken(debtTokenImplementation.clone());
        debtToken.initialize(debtName, debtSymbol, address(this));

        token = IERC20(token_);
        controller = IController(controller_);
        _chainlinkPriceFeed = AggregatorV3Interface(priceFeed_);

        _apy = 0;
        interestRatePerSecond = 0;
        lastUpdateTimestamp = block.timestamp;

        _totalUnlockedIntents = 0;
        _totalUnlocked = 0;
        locked = false;
    }

    function deposit(uint256 amount_) external override nonReentrant {
        token.safeTransferFrom(msg.sender, address(this), amount_);
        deToken.mint(msg.sender, amount_);

        _lastDeposited[msg.sender] = block.timestamp;

        emit Deposited(msg.sender, amount_, block.timestamp);
    }

    function unlock(uint256 amount_) external override nonReentrant tryWithdrawing(msg.sender) {
        unlockIntents[msg.sender] += amount_;
        unlockIntentTimings[msg.sender] = block.timestamp;

        deToken.burn(msg.sender, amount_);

        _totalUnlockedIntents += amount_;

        emit UnlockIntentPosted(msg.sender, amount_, block.timestamp);
    }

    function _lock() internal {
        if (locked) {
            revert AlreadyLocked();
        }

        locked = true;

        emit Locked(block.timestamp);
    }

    function _unlock() internal {
        if (!locked) {
            revert AlreadyUnlocked();
        }

        _totalUnlocked += _totalUnlockedIntents;
        _totalUnlockedIntents = 0;
        locked = false;
    }

    function withdraw() external override nonReentrant {
        uint256 amount = unlockIntents[msg.sender];

        if (amount == 0) {
            revert NoAmountUnlocked();
        }

        if (unlockIntentTimings[msg.sender] > lastUpdateTimestamp) {
            revert NoAmountUnlocked();
        }

        token.safeTransfer(msg.sender, amount);
        unlockIntents[msg.sender] = 0;
        _totalUnlocked -= amount;

        emit Withdrawn(msg.sender, amount, block.timestamp);
    }

    function _borrow(address account_, uint256 amount_) external override onlyController tryBorrowing(account_) {
        borrowIntents[account_] += amount_;
        borrowIntentTimings[account_] = block.timestamp;

        _totalUnlocked += amount_;

        emit BorrowIntentPosted(account_, amount_, block.timestamp);
    }

    function borrow() external override nonReentrant {
        uint256 amount = borrowIntents[msg.sender];

        if (amount == 0) {
            revert NoAmountUnlocked();
        }

        if (borrowIntentTimings[msg.sender] > lastUpdateTimestamp) {
            revert NoAmountUnlocked();
        }

        token.safeTransfer(msg.sender, amount);
        debtToken.mint(msg.sender, amount);
        borrowIntents[msg.sender] = 0;
        _totalUnlocked -= amount;

        emit Borrowed(msg.sender, amount, block.timestamp);
    }

    function _liquidate(address account_, address receiver_) external override onlyController {
        uint256 debt = debtToken.balanceOf(account_);
        uint256 collateral = deToken.balanceOf(account_);

        token.safeTransferFrom(receiver_, address(this), debt);
        deToken._poolTransfer(account_, receiver_, collateral);
        debtToken.burn(account_, debt);

        emit Liquidated(account_, receiver_, debt, block.timestamp);
    }

    function repay(uint256 amount_) external override {
        token.safeTransferFrom(msg.sender, address(this), amount_);
        debtToken.burn(msg.sender, amount_);

        emit Repaid(msg.sender, address(token), amount_, block.timestamp);
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
        return debtToken.balanceOf(account_) + borrowIntents[account_];
    }

    function debtOfInUSD(address account_) external view override returns (uint256) {
        uint8 chainlinkDecimals = _chainlinkPriceFeed.decimals();
        uint8 tokenDecimals = IERC20Metadata(address(token)).decimals();

        (, int256 answer,,,) = _chainlinkPriceFeed.latestRoundData();

        uint256 b = debtToken.balanceOf(account_) + borrowIntents[account_];
        uint256 p = answer.toUint256();

        return (b * p * 1e18) / (10 ** (tokenDecimals + chainlinkDecimals));
    }

    function amountCanBoorrow(address account_) external view override returns (uint256) {
        uint256 healthFactor = controller.healthFactorFor(account_);
        if (healthFactor <= RayMath.RAY) {
            return 0;
        }

        uint256 totalCollateral = controller.totalCollateralOfInUSD(account_);
        uint256 totalDebt = controller.totalDebtOfInUSD(account_);
        uint256 delta = totalCollateral - totalDebt;
        if (delta <= 0) {
            return 0;
        }

        uint256 liquidationThreshold = controller.liquidationThreshold();
        uint256 actualAmount = (delta * liquidationThreshold) / RayMath.RAY;

        (, int256 answer,,,) = _chainlinkPriceFeed.latestRoundData();
        uint8 chainlinkDecimals = _chainlinkPriceFeed.decimals();
        uint8 tokenDecimals = IERC20Metadata(address(token)).decimals();

        uint256 p = answer.toUint256();

        return (actualAmount * (10 ** (tokenDecimals + chainlinkDecimals - 18))) / p;
    }

    function balance() external view override returns (uint256) {
        if (_afterExecutionToken0Balance > 0) {
            return _afterExecutionToken0Balance - _totalUnlockedIntents - _totalUnlocked;
        } else if (_beforeExecutionToken0Balance > 0) {
            return _beforeExecutionToken0Balance - _totalUnlockedIntents - _totalUnlocked;
        }

        return token.balanceOf(address(this)) - _totalUnlockedIntents - _totalUnlocked;
    }

    function chainlinkPriceFeed() external view override returns (address) {
        return address(_chainlinkPriceFeed);
    }

    function apy() external view override returns (uint256) {
        return _apy;
    }

    function _updateAPY() internal {
        if (_afterExecutionToken0Balance > _beforeExecutionToken0Balance) {
            uint256 timeElapsed = block.timestamp - lastUpdateTimestamp;
            uint256 ratio = (
                ((_afterExecutionToken0Balance - _beforeExecutionToken0Balance) * RayMath.RAY)
                    / _beforeExecutionToken0Balance
            );

            uint256 ratioPerSecond = ratio / timeElapsed;
            uint256 ratioPerYear = ratioPerSecond * 365 days;

            _apy = ratioPerYear;
            interestRatePerSecond = ratioPerSecond;
            lastUpdateTimestamp = block.timestamp;

            return;
        }

        _apy = 0;
        interestRatePerSecond = 0;
        lastUpdateTimestamp = block.timestamp;
    }
}
