// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IMockAMMPool} from "../interfaces/IMockAMMPool.sol";
import {IMintableERC20} from "../interfaces/IMintableERC20.sol";

contract MockAMMPool is IMockAMMPool, Ownable {
    IMintableERC20 public token;
    uint256 public interestRatePerSecond;

    uint256 private _lastUpdateTimestamp;

    constructor(address token_, uint256 interestRatePerSecond_, address owner_) Ownable(owner_) {
        token = IMintableERC20(token_);
        interestRatePerSecond = interestRatePerSecond_;
        _lastUpdateTimestamp = block.timestamp;
    }

    function updateInterestRatePerSecond(uint256 interestRatePerSecond_) external onlyOwner {
        uint256 timeElapsed = block.timestamp - _lastUpdateTimestamp;
        if (timeElapsed == 0) {
            revert CannotUpdateInterestRatePerSecond();
        }

        _update();

        interestRatePerSecond = interestRatePerSecond_;
    }

    function _update() private {
        uint256 timeElapsed = block.timestamp - _lastUpdateTimestamp;
        uint256 interestEarned = (token.balanceOf(address(this)) * interestRatePerSecond * timeElapsed) / 1e18;
        token.mint(address(this), interestEarned);

        _lastUpdateTimestamp = block.timestamp;
    }
}
