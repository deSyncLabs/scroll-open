// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IMintableERC20} from "src/interfaces/IMintableERC20.sol";

contract MockMintableERC20 is IMintableERC20, ERC20, AccessControl {
    bytes32 public constant MINTER_BURNER_ROLE = keccak256("MINTER_BURNER_ROLE");
    bytes32 public constant OWNER_ROLE = keccak256("OWNER_ROLE");

    address public ammPool;

    uint256 private _mintAmount;
    mapping(address => uint256) private _lastMintedTimestamp;

    constructor(string memory name_, string memory symbol_, uint256 mintAmount_, address owner_)
        ERC20(name_, symbol_)
    {
        _mintAmount = mintAmount_;
        _grantRole(OWNER_ROLE, owner_);
        _setRoleAdmin(MINTER_BURNER_ROLE, OWNER_ROLE);
    }

    function mint() external override {
        uint256 timeElapsed = block.timestamp - _lastMintedTimestamp[_msgSender()];
        if (timeElapsed < 1 days) {
            revert CanMintOnlyOncePerDay(_lastMintedTimestamp[_msgSender()], timeElapsed);
        }

        _lastMintedTimestamp[_msgSender()] = block.timestamp;

        super._mint(_msgSender(), _mintAmount);
    }

    function _mint_(address account_, uint256 amount_) external override onlyRole(MINTER_BURNER_ROLE) {
        super._mint(account_, amount_);
    }

    function _burn_(address account_, uint256 amount_) external override onlyRole(MINTER_BURNER_ROLE) {
        super._burn(account_, amount_);
    }

    function _addMinterBurner(address account_) external override onlyRole(OWNER_ROLE) {
        _grantRole(MINTER_BURNER_ROLE, account_);
    }

    function _setAmmPool(address ammPool_) external override onlyRole(OWNER_ROLE) {
        ammPool = ammPool_;
    }

    function mintAmount() external view override returns (uint256) {
        return _mintAmount;
    }

    function lastMintedTimestamp(address account_) external view override returns (uint256) {
        return _lastMintedTimestamp[account_];
    }
}
