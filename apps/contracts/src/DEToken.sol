// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.20;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {RayMath} from "lib/RayMath.sol";
import {IDEToken} from "./interfaces/IDEToken.sol";
import {IPool} from "./interfaces/IPool.sol";

contract DEToken is IDEToken, ERC20, ReentrancyGuard, Ownable {
    IPool public pool;

    uint256 public lastYieldUpdate;

    constructor(string memory name_, string memory symbol_, address pool_) ERC20(name_, symbol_) Ownable(msg.sender) {
        pool = IPool(pool_);
        lastYieldUpdate = block.timestamp;
    }

    function balanceOf(address account) public view override(ERC20, IERC20) returns (uint256) {
        return super.balanceOf(account) * pool.liquidityIndex() / RayMath.RAY;
    }

    function transfer(address to_, uint256 value_) public override(ERC20, IERC20) nonReentrant returns (bool) {
        uint256 scaledValue = (value_ * RayMath.RAY + pool.liquidityIndex() - 1) / pool.liquidityIndex();
        super.transfer(to_, scaledValue);
        return true;
    }

    function transferFrom(address from_, address to_, uint256 value_)
        public
        override(ERC20, IERC20)
        nonReentrant
        returns (bool)
    {
        uint256 scaledValue = (value_ * RayMath.RAY + pool.liquidityIndex() - 1) / pool.liquidityIndex();
        super.transferFrom(from_, to_, scaledValue);
        return true;
    }

    function mint(address to_, uint256 value_) public onlyOwner nonReentrant {
        uint256 scaledValue = (value_ * RayMath.RAY + pool.liquidityIndex() - 1) / pool.liquidityIndex();
        _mint(to_, scaledValue);
    }

    function burn(address from_, uint256 value_) public onlyOwner nonReentrant {
        uint256 scaledValue = (value_ * RayMath.RAY + pool.liquidityIndex() - 1) / pool.liquidityIndex();
        _burn(from_, scaledValue);
    }

    function _poolTransfer(address from_, address to_, uint256 value_) public override onlyOwner nonReentrant {
        uint256 scaledValue = (value_ * RayMath.RAY + pool.liquidityIndex() - 1) / pool.liquidityIndex();
        _transfer(from_, to_, scaledValue);
    }

    function updateYieldDaily() external onlyOwner nonReentrant {
        lastYieldUpdate = block.timestamp;

        pool.updateLiquidityIndex();
    }
}
