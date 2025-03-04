// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.20;

import {TickMath} from "@uniswap/v3-core/contracts/libraries/TickMath.sol";
import {IERC721Receiver} from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ISwapRouter} from "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
import {INonfungiblePositionManager} from "@uniswap/v3-periphery/contracts/interfaces/INonfungiblePositionManager.sol";
import {TransferHelper} from "@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol";
import {Pool} from "./Pool.sol";
import {IFuturesMarket} from "./interfaces/IFuturesMarket.sol";

contract StratergyPool is Pool, IERC721Receiver {
    using TransferHelper for address;

    address private _token0;
    address private _token1;

    uint24 private _poolFee;
    uint256 private _tokenId;
    uint256 private _positionId;
    uint128 private _liquidity;

    INonfungiblePositionManager private _nonfungiblePositionManager;
    ISwapRouter private _swapRouter;
    IFuturesMarket private _futuresMarket;

    uint256 public lastExecutionTimestamp;
    bool public isStratergyActive;

    struct Deposit {
        address owner;
        uint128 liquidity;
        address token0;
        address token1;
    }

    constructor(
        address token0_,
        address controller_,
        address owner_,
        address token1_,
        uint24 poolFee_,
        address nonfungiblePositionManager_,
        address swapRouter_,
        address futuresMarket_,
        address priceFeed_
    ) Pool(token0_, controller_, priceFeed_, owner_) {
        _token0 = token0_;
        _token1 = token1_;

        _poolFee = poolFee_;
        _tokenId = 0;
        _positionId = 0;
        _liquidity = 0;

        _totalUnlocked = 0;
        _beforeExecutionToken0Balance = 0;
        _afterExecutionToken0Balance = 0;

        lastExecutionTimestamp = 0;
        isStratergyActive = false;

        _nonfungiblePositionManager = INonfungiblePositionManager(nonfungiblePositionManager_);
        _swapRouter = ISwapRouter(swapRouter_);
        _futuresMarket = IFuturesMarket(futuresMarket_);
    }

    function executeStratergy() external override onlyOwner {
        if (isStratergyActive) {
            revert StratergyAlreadyActive();
        }

        _beforeExecutionToken0Balance = IERC20(_token0).balanceOf(address(this)) - _totalUnlocked;

        uint256 amount0Provided;
        _swapHalfForToken1(IERC20(_token0).balanceOf(address(this)) - _totalUnlocked);

        if (_tokenId == 0) {
            (uint256 tokenId, uint128 liquidity, uint256 amount0,) = _mintNeAMMPosition(
                IERC20(_token0).balanceOf(address(this)) - _totalUnlocked, IERC20(_token1).balanceOf(address(this))
            );

            _tokenId = tokenId;
            _liquidity = liquidity;
            amount0Provided = amount0;
        } else {
            (uint256 amount0, uint256 amount1) = _collectAllAMMFees(_tokenId);

            uint256 amount0ToMint = (IERC20(_token0).balanceOf(address(this)) - _totalUnlocked) + amount0;
            uint256 amount1ToMint = (IERC20(_token1).balanceOf(address(this))) + amount1;

            (_liquidity, amount0Provided,) = _increaseLiquidity(_tokenId, amount0ToMint, amount1ToMint);
        }

        _token0.safeApprove(address(_futuresMarket), type(uint256).max);
        _token1.safeApprove(address(_futuresMarket), type(uint256).max);

        _positionId = _futuresMarket.openPosition(_token0, _token1, amount0Provided, false);

        _token0.safeApprove(address(_futuresMarket), 0);
        _token1.safeApprove(address(_futuresMarket), 0);

        lastExecutionTimestamp = block.timestamp;
        isStratergyActive = true;

        _lock();

        emit StartedStratergy(block.timestamp);
    }

    function unexecuteStratergy() external override onlyOwner {
        if (!isStratergyActive) {
            revert StratergyNotActive();
        }

        if (_tokenId == 0) {
            revert StratergyNotInitialized();
        }

        _decreaseLiquidity(_tokenId, _liquidity);
        _liquidity = 0;

        _token0.safeApprove(address(_futuresMarket), type(uint256).max);
        _token1.safeApprove(address(_futuresMarket), type(uint256).max);

        _futuresMarket.closePosition(_positionId);

        _token0.safeApprove(address(_futuresMarket), 0);
        _token1.safeApprove(address(_futuresMarket), 0);

        _swapEverythingForToken0();

        _positionId = 0;
        isStratergyActive = false;
        _afterExecutionToken0Balance = IERC20(_token0).balanceOf(address(this)) - _totalUnlocked;

        _updateAPY();
        _unlock();

        emit StoppedStratergy(block.timestamp);
    }

    function _mintNeAMMPosition(uint256 amount0ToMint, uint256 amount1ToMint)
        private
        returns (uint256, uint128, uint256, uint256)
    {
        _token0.safeApprove(address(_nonfungiblePositionManager), amount0ToMint);
        _token1.safeApprove(address(_nonfungiblePositionManager), amount1ToMint);

        INonfungiblePositionManager.MintParams memory params = INonfungiblePositionManager.MintParams({
            token0: _token0,
            token1: _token1,
            fee: _poolFee,
            tickLower: TickMath.MIN_TICK,
            tickUpper: TickMath.MAX_TICK,
            amount0Desired: amount0ToMint,
            amount1Desired: amount1ToMint,
            amount0Min: 0,
            amount1Min: 0,
            recipient: address(this),
            deadline: block.timestamp
        });

        (uint256 tokenId, uint128 liquidity, uint256 amount0, uint256 amount1) =
            _nonfungiblePositionManager.mint(params);

        _token0.safeApprove(address(_nonfungiblePositionManager), 0);
        _token1.safeApprove(address(_nonfungiblePositionManager), 0);

        return (tokenId, liquidity, amount0, amount1);
    }

    function _increaseLiquidity(uint256 tokenId_, uint256 amountAdd0_, uint256 amountAdd1_)
        private
        returns (uint128, uint256, uint256)
    {
        _token0.safeApprove(address(_nonfungiblePositionManager), amountAdd0_);
        _token1.safeApprove(address(_nonfungiblePositionManager), amountAdd1_);

        INonfungiblePositionManager.IncreaseLiquidityParams memory params = INonfungiblePositionManager
            .IncreaseLiquidityParams({
            tokenId: tokenId_,
            amount0Desired: amountAdd0_,
            amount1Desired: amountAdd1_,
            amount0Min: 0,
            amount1Min: 0,
            deadline: block.timestamp
        });

        (uint128 liquidity, uint256 amount0, uint256 amount1) = _nonfungiblePositionManager.increaseLiquidity(params);

        _token0.safeApprove(address(_nonfungiblePositionManager), 0);
        _token1.safeApprove(address(_nonfungiblePositionManager), 0);

        return (liquidity, amount0, amount1);
    }

    function _decreaseLiquidity(uint256 tokenId_, uint128 liquidity_) private returns (uint256, uint256) {
        INonfungiblePositionManager.DecreaseLiquidityParams memory params = INonfungiblePositionManager
            .DecreaseLiquidityParams({
            tokenId: tokenId_,
            liquidity: liquidity_,
            amount0Min: 0,
            amount1Min: 0,
            deadline: block.timestamp
        });

        (uint256 amount0, uint256 amount1) = _nonfungiblePositionManager.decreaseLiquidity(params);

        return (amount0, amount1);
    }

    function _collectAllAMMFees(uint256 tokenId_) private returns (uint256, uint256) {
        INonfungiblePositionManager.CollectParams memory params = INonfungiblePositionManager.CollectParams({
            tokenId: tokenId_,
            recipient: address(this),
            amount0Max: type(uint128).max,
            amount1Max: type(uint128).max
        });

        (uint256 amount0, uint256 amount1) = _nonfungiblePositionManager.collect(params);

        return (amount0, amount1);
    }

    function _swapHalfForToken1(uint256 amount0_) private returns (uint256) {
        _token0.safeApprove(address(_swapRouter), amount0_);

        ISwapRouter.ExactInputSingleParams memory params = ISwapRouter.ExactInputSingleParams({
            tokenIn: _token0,
            tokenOut: _token1,
            fee: _poolFee,
            recipient: address(this),
            deadline: block.timestamp,
            amountIn: amount0_ / 2,
            amountOutMinimum: 0,
            sqrtPriceLimitX96: 0
        });

        uint256 amountOut = _swapRouter.exactInputSingle(params);

        _token0.safeApprove(address(_swapRouter), 0);

        return amountOut;
    }

    function _swapEverythingForToken0() private returns (uint256) {
        _token1.safeApprove(address(_swapRouter), IERC20(_token1).balanceOf(address(this)));

        ISwapRouter.ExactInputSingleParams memory params = ISwapRouter.ExactInputSingleParams({
            tokenIn: _token1,
            tokenOut: _token0,
            fee: _poolFee,
            recipient: address(this),
            deadline: block.timestamp,
            amountIn: IERC20(_token1).balanceOf(address(this)),
            amountOutMinimum: 0,
            sqrtPriceLimitX96: 0
        });

        uint256 amountOut = _swapRouter.exactInputSingle(params);

        _token1.safeApprove(address(_swapRouter), 0);

        return amountOut;
    }

    function onERC721Received(address, address, uint256, bytes calldata) external pure override returns (bytes4) {
        return this.onERC721Received.selector;
    }
}
