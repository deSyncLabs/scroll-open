// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IMockAMMPool} from "../interfaces/IMockAMMPool.sol";
import {IMintableERC20} from "../interfaces/IMintableERC20.sol";

contract MockAMMPool is IMockAMMPool, Ownable {
    using SafeERC20 for IMintableERC20;

    IMintableERC20 public token;
    uint256 public interestRatePerSecond;
    address public pool;

    uint256 private _lastUpdateTimestamp;

    modifier onlyPool() {
        if (msg.sender != pool) {
            revert OnlyPool();
        }

        _;
    }

    constructor(address token_, uint256 interestRatePerSecond_, address owner_, address pool_) Ownable(owner_) {
        token = IMintableERC20(token_);
        interestRatePerSecond = interestRatePerSecond_;
        _lastUpdateTimestamp = block.timestamp;
        pool = pool_;
    }

    function deposit(uint256 amount_) external override onlyPool {
        _update();

        token.safeTransferFrom(msg.sender, address(this), amount_);
    }

    function withdraw(uint256 amount_) external onlyPool {
        _update();

        token.safeTransfer(msg.sender, amount_);
    }

    function updateInterestRatePerSecond(uint256 interestRatePerSecond_) external onlyOwner {
        uint256 timeElapsed = block.timestamp - _lastUpdateTimestamp;
        if (timeElapsed == 0) {
            revert CannotUpdateInterestRatePerSecond();
        }

        _update();

        interestRatePerSecond = interestRatePerSecond_;
    }

    function balance() external view override returns (uint256) {
        uint256 timeElapsed = block.timestamp - _lastUpdateTimestamp;
        uint256 interestEarned = (token.balanceOf(address(this)) * interestRatePerSecond * timeElapsed) / 1e18;

        return token.balanceOf(address(this)) + interestEarned;
    }

    function _update() private {
        uint256 timeElapsed = block.timestamp - _lastUpdateTimestamp;
        uint256 interestEarned = (token.balanceOf(address(this)) * interestRatePerSecond * timeElapsed) / 1e18;
        token.mint(address(this), interestEarned);

        _lastUpdateTimestamp = block.timestamp;
    }
}
