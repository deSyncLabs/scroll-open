// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {AggregatorV3Interface} from "@chainlink/interfaces/feeds/AggregatorV3Interface.sol";
import {IMintableERC20} from "src/interfaces/IMintableERC20.sol";

contract MockFuturesMarket is AccessControl {
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant AUTHORIZED_ROLE = keccak256("AUTHORIZED_ROLE");

    error PriceFeedNotFound(address token_);

    error SizeMismatch();

    mapping(address token_ => AggregatorV3Interface) private _priceFeeds;

    struct Position {
        address token0;
        address token1;
        uint256 amount0;
        uint256 amount1;
        bool isLong;
        uint256 priceInTermsOfToken1AtEntry;
        uint256 timestamp;
    }

    uint256 private _positionId;

    mapping(uint256 tokenId_ => Position) private _positions;

    constructor(address[] memory tokens_, address[] memory priceFeeds_, address admin_) {
        if (tokens_.length != priceFeeds_.length) {
            revert SizeMismatch();
        }

        for (uint256 i = 0; i < tokens_.length; i++) {
            _priceFeeds[tokens_[i]] = AggregatorV3Interface(priceFeeds_[i]);
        }

        _positionId = 0;

        _grantRole(ADMIN_ROLE, admin_);
        _setRoleAdmin(AUTHORIZED_ROLE, ADMIN_ROLE);
    }

    function openPosition(address token0_, address token1_, uint256 amount0_, bool isLong_)
        external
        onlyRole(AUTHORIZED_ROLE)
        returns (uint256)
    {
        if (_priceFeeds[token0_] == AggregatorV3Interface(address(0))) {
            revert PriceFeedNotFound(token0_);
        }

        if (_priceFeeds[token1_] == AggregatorV3Interface(address(0))) {
            revert PriceFeedNotFound(token1_);
        }

        _positionId++;

        (, int256 price0,,,) = _priceFeeds[token0_].latestRoundData();
        (, int256 price1,,,) = _priceFeeds[token1_].latestRoundData();

        uint8 decimals0 = _priceFeeds[token0_].decimals();
        uint8 decimals1 = _priceFeeds[token1_].decimals();

        uint256 priceInTermsOfToken1AtEntry = uint256(price0) * 10 ** decimals1 / uint256(price1) / 10 ** decimals0;

        _positions[_positionId] = Position(
            token0_,
            token1_,
            amount0_,
            amount0_ * priceInTermsOfToken1AtEntry,
            isLong_,
            priceInTermsOfToken1AtEntry,
            block.timestamp
        );

        return _positionId;
    }

    function closePosition(uint256 positionId_) external onlyRole(AUTHORIZED_ROLE) returns (bool, uint256) {
        Position memory position = _positions[positionId_];

        (, int256 price0,,,) = _priceFeeds[position.token0].latestRoundData();
        (, int256 price1,,,) = _priceFeeds[position.token1].latestRoundData();

        uint8 decimals0 = _priceFeeds[position.token0].decimals();
        uint8 decimals1 = _priceFeeds[position.token1].decimals();

        uint256 priceInTermsOfToken1AtExit = uint256(price0) * (10 ** decimals1) / uint256(price1) / (10 ** decimals0);

        bool isProfit = false;
        uint256 profitOrLoss = 0;

        uint256 pa0 = position.amount0 * priceInTermsOfToken1AtExit;
        uint256 pa1 = position.amount1;

        if (position.isLong) {
            if (pa0 > pa1) {
                isProfit = true;
                profitOrLoss = pa0 - pa1;
            } else {
                isProfit = false;
                profitOrLoss = pa1 - pa0;
            }
        } else {
            if (pa0 > pa1) {
                isProfit = true;
                profitOrLoss = pa0 - pa1;
            } else {
                isProfit = false;
                profitOrLoss = pa1 - pa0;
            }
        }

        if (isProfit) {
            IMintableERC20(position.token1)._mint_(msg.sender, profitOrLoss);
        } else {
            // We are using try and catch in the mock just to avoid deadlocks. In the real implementation we will leverage a flash loan and Off Exchange Settlement Provider to settle the trade.
            try IMintableERC20(position.token1)._burn_(msg.sender, profitOrLoss) {} catch {}
        }

        delete _positions[positionId_];

        return (isProfit, profitOrLoss);
    }

    function addPriceFeed(address token_, address priceFeed_) external onlyRole(ADMIN_ROLE) {
        _priceFeeds[token_] = AggregatorV3Interface(priceFeed_);
    }

    function _addAuthorized(address account_) external onlyRole(ADMIN_ROLE) {
        _grantRole(AUTHORIZED_ROLE, account_);
    }
}
