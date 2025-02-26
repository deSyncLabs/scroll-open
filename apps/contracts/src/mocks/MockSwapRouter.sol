// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ISwapRouter} from "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
import {AggregatorV3Interface} from "@chainlink/interfaces/feeds/AggregatorV3Interface.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {SafeCast} from "@openzeppelin/contracts/utils/math/SafeCast.sol";
import {IMintableERC20} from "src/interfaces/IMintableERC20.sol";

contract MockSwapRouter is Ownable {
    using SafeCast for int256;

    error SizeMismatch();
    error InvalidPriceFeed(address token_);

    mapping(address token_ => AggregatorV3Interface priceFeed_) private _priceFeeds;

    constructor(address[] memory tokens_, address[] memory priceFeeds_, address owner_) Ownable(owner_) {
        if (tokens_.length != priceFeeds_.length) {
            revert SizeMismatch();
        }

        for (uint256 i = 0; i < tokens_.length; i++) {
            _priceFeeds[tokens_[i]] = AggregatorV3Interface(priceFeeds_[i]);
        }
    }

    function setPriceFeed(address token_, address priceFeed_) external onlyOwner {
        _priceFeeds[token_] = AggregatorV3Interface(priceFeed_);
    }

    function exactInputSingle(ISwapRouter.ExactInputSingleParams memory params_) external returns (uint256){
        AggregatorV3Interface inPriceFeed = _priceFeeds[params_.tokenIn];
        AggregatorV3Interface outPriceFeed = _priceFeeds[params_.tokenOut];

        if (address(inPriceFeed) == address(0)) {
            revert InvalidPriceFeed(params_.tokenIn);
        }

        if (address(outPriceFeed) == address(0)) {
            revert InvalidPriceFeed(params_.tokenOut);
        }

        (, int256 inPrice,,,) = inPriceFeed.latestRoundData();
        (, int256 outPrice,,,) = outPriceFeed.latestRoundData();

        uint256 inPrice18 = inPrice.toUint256() * 10 ** (18 - inPriceFeed.decimals());
        uint256 outPrice18 = outPrice.toUint256() * 10 ** (18 - outPriceFeed.decimals());


        uint256 amountOut = params_.amountIn * inPrice18 / outPrice18;

        IMintableERC20(params_.tokenIn)._burn_(msg.sender, params_.amountIn);
        IMintableERC20(params_.tokenOut)._mint_(msg.sender, amountOut);

        return amountOut;
    }
}
