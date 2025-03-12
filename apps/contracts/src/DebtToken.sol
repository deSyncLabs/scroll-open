// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC20Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {ReentrancyGuardUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IDebtToken} from "./interfaces/IDebtToken.sol";

contract DebtToken is IDebtToken, ERC20Upgradeable, OwnableUpgradeable, ReentrancyGuardUpgradeable {
    // in memory of the old constructor
    // constructor(string memory name_, string memory symbol_, address pool_) ERC20(name_, symbol_) Ownable(pool_) {}

    function initialize(string memory name_, string memory symbol_, address pool_) external override initializer {
        __ERC20_init(name_, symbol_);
        __Ownable_init(pool_);
        __ReentrancyGuard_init();
    }

    function mint(address account_, uint256 amount_) external override onlyOwner nonReentrant {
        _mint(account_, amount_);
    }

    function burn(address account_, uint256 amount_) external override onlyOwner nonReentrant {
        _burn(account_, amount_);
    }

    function deTransferFrom(address from_, address to_, uint256 amount_) external override onlyOwner nonReentrant {
        _transfer(from_, to_, amount_);
    }

    function approve(address, uint256) public pure override(ERC20Upgradeable, IERC20) returns (bool) {
        revert NotAllowed();
    }

    function transfer(address, uint256) public pure override(ERC20Upgradeable, IERC20) returns (bool) {
        revert NotAllowed();
    }

    function transferFrom(address, address, uint256) public pure override(ERC20Upgradeable, IERC20) returns (bool) {
        revert NotAllowed();
    }
}
