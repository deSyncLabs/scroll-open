// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IMintableERC20} from "../interfaces/IMintableERC20.sol";

contract MockMintableERC20 is IMintableERC20, ERC20, AccessControl {
    bytes32 public constant MINTER_BURNER_ROLE = keccak256("MINTER_BURNER_ROLE");

    address public ammPool;
    mapping(address => uint256) private _lastMintedTimestamp;

    constructor(string memory name_, string memory symbol_, address ammPool_) ERC20(name_, symbol_) {
        ammPool = ammPool_;
        grantRole(MINTER_BURNER_ROLE, ammPool_);
    }

    function mint(uint256 amount_) external override {
        uint256 timeElapsed = block.timestamp - _lastMintedTimestamp[_msgSender()];
        if (timeElapsed < 1 days) {
            revert CanMintOnlyOncePerDay(_lastMintedTimestamp[_msgSender()], timeElapsed);
        }

        super._mint(_msgSender(), amount_);
    }

    function _mint_(address account_, uint256 amount_) external override onlyRole(MINTER_BURNER_ROLE) {
        super._mint(account_, amount_);
    }

    function _burn_(address account_, uint256 amount_) external override onlyRole(MINTER_BURNER_ROLE) {
        super._burn(account_, amount_);
    }

    function lastMintedTimestamp(address account_) external view override returns (uint256) {
        return _lastMintedTimestamp[account_];
    }
}
