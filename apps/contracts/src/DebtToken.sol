// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.20;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {IDebtToken} from "./interfaces/IDebtToken.sol";
import {IPool} from "./interfaces/IPool.sol";

contract DebtToken is IDebtToken, ERC20 {
    IPool pool;

    modifier onlyPool() {
        if (msg.sender != address(pool)) {
            revert OnlyPool();
        }

        _;
    }

    constructor(string memory name_, string memory symbol_, address pool_) ERC20(name_, symbol_) {
        pool = IPool(pool_);
    }

    function mint(address account_, uint256 amount_) external override onlyPool {
        _mint(account_, amount_);
    }

    function burn(address account_, uint256 amount_) external override onlyPool {
        _burn(account_, amount_);
    }

    function deTransfer(address from_, address to_, uint256 amount_) external onlyPool {
        _transfer(from_, to_, amount_);
    }

    function approve(address, uint256) public pure override returns (bool) {
        revert NotAllowed();
    }

    function transfer(address, uint256) public pure override returns (bool) {
        revert NotAllowed();
    }

    function transferFrom(address, address, uint256) public pure override returns (bool) {
        revert NotAllowed();
    }
}
