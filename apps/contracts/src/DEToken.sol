// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC20Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {ReentrancyGuardUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import {Initializable} from "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {RayMath} from "lib/RayMath.sol";
import {IDEToken} from "./interfaces/IDEToken.sol";
import {IPool} from "./interfaces/IPool.sol";
import {IController} from "./interfaces/IController.sol";

contract DEToken is IDEToken, ERC20Upgradeable, ReentrancyGuardUpgradeable, OwnableUpgradeable {
    IPool public pool;

    uint256 public lastYieldUpdate;
    address public externalOwner;

    mapping(address => uint256) public lastActionTimestamp;

    modifier onlyExternalOwner() {
        if (msg.sender != externalOwner) {
            revert OnlyExternalOwner();
        }

        _;
    }

    modifier mintInterest(address user_) {
        uint256 interestEarned = _getInterestEarnedByAUser(user_);

        if (interestEarned > 0) {
            _mint(user_, interestEarned);
        }

        _;

        lastActionTimestamp[user_] = block.timestamp;
    }

    modifier noDebt(address user_) {
        IController controller = pool.controller();

        if (controller.healthFactorFor(user_) < type(uint256).max) {
            revert DebtExists(controller.totalDebtOfInUSD(user_));
        }

        _;
    }

    // in memory of the old constructor
    // constructor(string memory name_, string memory symbol_, address pool_, address owner_, address externalOwner_) {
    //     pool = IPool(pool_);
    //     lastYieldUpdate = block.timestamp;

    //     externalOwner = externalOwner_;
    // }

    function initialize(
        string memory name_,
        string memory symbol_,
        address pool_,
        address owner_,
        address externalOwner_
    ) external override initializer {
        __ERC20_init(name_, symbol_);
        __Ownable_init(owner_);
        __ReentrancyGuard_init();

        pool = IPool(pool_);
        lastYieldUpdate = block.timestamp;

        externalOwner = externalOwner_;
    }

    function balanceOf(address account_) public view override(IERC20, ERC20Upgradeable) returns (uint256) {
        return super.balanceOf(account_) + _getInterestEarnedByAUser(account_);
    }

    function transfer(address to_, uint256 value_)
        public
        override(IERC20, ERC20Upgradeable)
        nonReentrant
        mintInterest(msg.sender)
        noDebt(msg.sender)
        returns (bool)
    {
        return super.transfer(to_, value_);
    }

    function transferFrom(address from_, address to_, uint256 value_)
        public
        override(IERC20, ERC20Upgradeable)
        nonReentrant
        mintInterest(from_)
        mintInterest(to_)
        noDebt(from_)
        returns (bool)
    {
        return super.transferFrom(from_, to_, value_);
    }

    function update(address account_) public override {
        uint256 interestEarned = _getInterestEarnedByAUser(account_);

        if (!(interestEarned > 0)) {
            revert NoInterestEarned();
        }

        _mint(account_, interestEarned);
        lastActionTimestamp[account_] = block.timestamp;
    }

    function mint(address to_, uint256 value_) public onlyOwner mintInterest(to_) nonReentrant {
        _mint(to_, value_);
    }

    function burn(address from_, uint256 value_) public onlyOwner mintInterest(from_) nonReentrant {
        _burn(from_, value_);
    }

    function _poolTransfer(address from_, address to_, uint256 value_)
        public
        override
        mintInterest(from_)
        mintInterest(to_)
        onlyOwner
        nonReentrant
    {
        _transfer(from_, to_, value_);
    }

    function _getInterestEarnedByAUser(address user_) private view returns (uint256) {
        uint256 balance = super.balanceOf(user_);
        uint256 lastPoolUpdate = pool.lastUpdateTimestamp();
        uint256 lastAction = lastActionTimestamp[user_];

        if (lastAction == 0) {
            return 0;
        }

        if (lastAction > lastPoolUpdate) {
            return 0;
        }

        uint256 timeElapsed = lastPoolUpdate - lastAction;
        uint256 interestEarned = (balance * pool.interestRatePerSecond() * timeElapsed) / RayMath.RAY;

        return interestEarned;
    }
}
