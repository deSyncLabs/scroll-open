// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.20;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IDebtToken} from "./interfaces/IDebtToken.sol";

contract DebtToken is IDebtToken, ERC20, Ownable {
    constructor(string memory name_, string memory symbol_, address pool_) ERC20(name_, symbol_) Ownable(pool_) {}

    function mint(address account_, uint256 amount_) external override onlyOwner {
        _mint(account_, amount_);
    }

    function burn(address account_, uint256 amount_) external override onlyOwner {
        _burn(account_, amount_);
    }

    function deTransferFrom(address from_, address to_, uint256 amount_) external override onlyOwner {
        _transfer(from_, to_, amount_);
    }

    function approve(address, uint256) public pure override(ERC20, IERC20) returns (bool) {
        revert NotAllowed();
    }

    function transfer(address, uint256) public pure override(ERC20, IERC20) returns (bool) {
        revert NotAllowed();
    }

    function transferFrom(address, address, uint256) public pure override(ERC20, IERC20) returns (bool) {
        revert NotAllowed();
    }
}
