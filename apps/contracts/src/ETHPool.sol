// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.20;

import {IUniswapV3Pool} from "@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol";
import {TickMath} from "@uniswap/v3-core/contracts/libraries/TickMath.sol";
import {IERC721Receiver} from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import {ISwapRouter} from "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
import {INonfungiblePositionManager} from "@uniswap/v3-periphery/contracts/interfaces/INonfungiblePositionManager.sol";
import {TransferHelper} from "@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol";
import {LiquidityManagement} from "@uniswap/v3-periphery/contracts/base/LiquidityManagement.sol";
import {Pool} from "./Pool.sol";

contract ETHPool is Pool, IERC721Receiver {
    address private _token0;
    address private _token1;

    uint24 private _poolFee;

    INonfungiblePositionManager private _nonfungiblePositionManager;

    constructor(
        address token_,
        uint256 apy_,
        address controller_,
        address owner_,
        address token0_,
        address token1_,
        address ammPool_,
        uint24 poolFee_,
        address nonfungiblePositionManager_

    ) Pool(token_, apy_, controller_, owner_)  {
        _token0 = token0_;
        _token1 = token1_;

        _poolFee = poolFee_;

        _nonfungiblePositionManager = INonfungiblePositionManager(nonfungiblePositionManager_);
    }

    function _stratergy() internal override {}
}
