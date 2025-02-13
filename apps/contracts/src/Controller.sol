// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.20;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Pool} from "./Pool.sol";
import {IPool} from "./interfaces/IPool.sol";
import {IController} from "./interfaces/IController.sol";

contract Controller is IController, Ownable {
    mapping(address token => IPool) _pools;
    IPool[] _poolList;

    constructor() Ownable(msg.sender) {}

    function createPool(address token_, uint256 apy_) external override onlyOwner {
        if (address(_pools[token_]) != address(0)) {
            revert PoolAlreadyExists();
        }

        _pools[token_] = new Pool(token_, apy_, address(this));
    }

    function addPool(address token_, address pool_) external override onlyOwner {
        if (address(_pools[token_]) != address(0)) {
            revert PoolAlreadyExists();
        }

        _pools[token_] = IPool(pool_);
        _poolList.push(IPool(pool_));
    }

    function removePool(address token_) external override onlyOwner {
        if (address(_pools[token_]) == address(0)) {
            revert PoolDoesNotExist();
        }

        delete _pools[token_];

        for (uint256 i = 0; i < _poolList.length; i++) {
            if (address(_poolList[i]) == address(_pools[token_])) {
                _poolList[i] = _poolList[_poolList.length - 1];
                _poolList.pop();
                break;
            }
        }
    }

    function poolFor(address token_) external view override returns (address) {
        return address(_pools[token_]);
    }

    function totalCollateralOfInUSD(address account_) external view override returns (uint256) {
        uint256 totalCollateral = 0;

        for (uint256 i = 0; i < _poolList.length; i++) {
            totalCollateral += _poolList[i].collateralOfInUSD(account_);
        }

        return totalCollateral;
    }

    function totalDebtOfInUSD(address account_) external view override returns (uint256) {
        uint256 totalDebt = 0;

        for (uint256 i = 0; i < _poolList.length; i++) {
            totalDebt += _poolList[i].debtOfInUSD(account_);
        }

        return totalDebt;
    }
}
