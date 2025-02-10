// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.20;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {RayMath} from "lib/RayMath.sol";
import {DEToken} from "./DEToken.sol";
import {IPool} from "./interfaces/IPool.sol";
import {IDEToken} from "./interfaces/IDEToken.sol";

contract Pool is IPool, ReentrancyGuard {
    using SafeERC20 for IERC20;

    IERC20 public token;
    IDEToken public deToken;

    uint256 public liquidityIndex;
    uint256 public interestRatePerSecond;
    uint256 public lastUpdateTimestamp;

    mapping(address => uint256) public unlocked;

    modifier onlyDEToken() {
        if (msg.sender != address(deToken)) {
            revert OnlyDEToken();
        }

        _;
    }

    constructor(address token_, uint256 apy_) {
        string memory name = string.concat("deSync ", IERC20Metadata(token_).name());
        string memory symbol = string.concat("de", IERC20Metadata(token_).symbol());

        token = IERC20(token_);
        deToken = new DEToken(name, symbol, address(this));

        liquidityIndex = RayMath.RAY;
        interestRatePerSecond = apy_ / 365 days;
        lastUpdateTimestamp = block.timestamp;
    }

    function deposit(uint256 amount_) external override nonReentrant {
        deToken.mint(msg.sender, amount_);
    }

    function unlock(uint256 amount_) external override nonReentrant {
        deToken.burn(msg.sender, amount_);
        unlocked[msg.sender] += amount_;

        emit UnlockIntentPosted(msg.sender, amount_, block.timestamp);
    }

    function withdraw() external override nonReentrant {
        uint256 amount = unlocked[msg.sender];
        unlocked[msg.sender] = 0;

        token.safeTransfer(msg.sender, amount);

        emit Withdrawn(msg.sender, amount, block.timestamp);
    }

    function borrow(uint256 amount_) external override nonReentrant {}

    function updateLiquidityIndex() external override {
        uint256 timeElapsed = block.timestamp - lastUpdateTimestamp;

        if (timeElapsed > 0) {
            liquidityIndex = liquidityIndex * (RayMath.RAY + interestRatePerSecond * timeElapsed) / RayMath.RAY;
            lastUpdateTimestamp = block.timestamp;
        }
    }
}
