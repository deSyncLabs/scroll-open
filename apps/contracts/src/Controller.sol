// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.20;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeCast} from "@openzeppelin/contracts/utils/math/SafeCast.sol";
import {IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import {AggregatorV3Interface} from "@chainlink/interfaces/feeds/AggregatorV3Interface.sol";
import {RayMath} from "lib/RayMath.sol";
import {StratergyPool} from "./StratergyPool.sol";
import {IPool} from "./interfaces/IPool.sol";
import {IController} from "./interfaces/IController.sol";

contract Controller is IController, Ownable {
    using SafeCast for int256;

    mapping(address token => IPool) _pools;
    IPool[] _poolList;

    uint256 public liquidationThreshold;

    constructor(uint256 liquidationThreshold_, address owner_) Ownable(owner_) {
        if (liquidationThreshold_ > RayMath.RAY) {
            revert LiquidationThresholdMustBeLessThan100();
        }

        liquidationThreshold = liquidationThreshold_;
    }

    function createStartergyPool(
        address token0_,
        address token1_,
        uint24 poolFee_,
        address nonFungiblePositionManager_,
        address swapRouter_,
        address futuresMarket_,
        address priceFeed_,
        address owner_
    ) external override onlyOwner returns (address) {
        if (address(_pools[token0_]) != address(0)) {
            revert PoolAlreadyExists();
        }

        _pools[token0_] = new StratergyPool(
            token0_,
            address(this),
            owner_,
            token1_,
            poolFee_,
            nonFungiblePositionManager_,
            swapRouter_,
            futuresMarket_,
            priceFeed_
        );
        _poolList.push(_pools[token0_]);

        emit PoolAdded(token0_, address(_pools[token0_]), block.timestamp);

        return address(_pools[token0_]);
    }

    function addPool(address pool_) external override onlyOwner {
        address token = address(IPool(pool_).token());

        if (address(_pools[token]) != address(0)) {
            revert PoolAlreadyExists();
        }

        _pools[token] = IPool(pool_);
        _poolList.push(IPool(pool_));

        emit PoolAdded(token, pool_, block.timestamp);
    }

    function removePool(address token_) external override onlyOwner {
        if (address(_pools[token_]) == address(0)) {
            revert PoolDoesNotExist();
        }

        address pool = address(_pools[token_]);

        delete _pools[token_];

        for (uint256 i = 0; i < _poolList.length; i++) {
            if (address(_poolList[i]) == address(_pools[token_])) {
                _poolList[i] = _poolList[_poolList.length - 1];
                _poolList.pop();
                break;
            }
        }

        emit PoolRemoved(token_, pool, block.timestamp);
    }

    function borrow(address token_, uint256 amount_) external override {
        if (address(_pools[token_]) == address(0)) {
            revert PoolDoesNotExist();
        }

        uint256 totalDebt = totalDebtOfInUSD(msg.sender);
        uint256 totalCollateral = totalCollateralOfInUSD(msg.sender);

        AggregatorV3Interface priceFeed = AggregatorV3Interface(_pools[token_].chainlinkPriceFeed());
        (, int256 tokenPrice,,,) = priceFeed.latestRoundData();

        uint8 tokenPriceDecimals = priceFeed.decimals();
        uint8 tokenDecimals = IERC20Metadata(token_).decimals();

        uint256 amountInUSD = (amount_ * tokenPrice.toUint256() * 1e18) / (10 ** (tokenPriceDecimals + tokenDecimals));
        totalDebt += amountInUSD;

        if (_calculateHealthFactor(totalCollateral, totalDebt) <= RayMath.RAY) {
            revert CollateralNotEnough();
        }

        _pools[token_]._borrow(msg.sender, amount_);
    }

    function liquidate(address account_) external override {
        uint256 totalCollateral = totalCollateralOfInUSD(account_);
        uint256 totalDebt = totalDebtOfInUSD(account_);

        if (_calculateHealthFactor(totalCollateral, totalDebt) > RayMath.RAY) {
            revert LiquidationThresholdNotReached();
        }

        for (uint256 i = 0; i < _poolList.length; i++) {
            if (_poolList[i].debtOfInUSD(account_) > 0) {
                _poolList[i]._liquidate(account_, msg.sender);
            }
        }
    }

    function poolFor(address token_) external view override returns (address) {
        return address(_pools[token_]);
    }

    function totalCollateralOfInUSD(address account_) public view override returns (uint256) {
        uint256 totalCollateral = 0;

        for (uint256 i = 0; i < _poolList.length; i++) {
            totalCollateral += _poolList[i].collateralOfInUSD(account_);
        }

        return totalCollateral;
    }

    function totalDebtOfInUSD(address account_) public view override returns (uint256) {
        uint256 totalDebt = 0;

        for (uint256 i = 0; i < _poolList.length; i++) {
            totalDebt += _poolList[i].debtOfInUSD(account_);
        }

        return totalDebt;
    }

    function healthFactorFor(address account_) external view override returns (uint256) {
        uint256 totalCollateral = totalCollateralOfInUSD(account_);
        uint256 totalDebt = totalDebtOfInUSD(account_);

        return _calculateHealthFactor(totalCollateral, totalDebt);
    }

    function _calculateHealthFactor(uint256 totalCollateral_, uint256 totalDebt_) private view returns (uint256) {
        if (totalDebt_ == 0) {
            return type(uint256).max;
        }

        return (totalCollateral_ * liquidationThreshold) / totalDebt_;
    }
}
