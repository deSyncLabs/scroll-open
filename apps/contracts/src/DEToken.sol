// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.20;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {Initializable} from "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import {RayMath} from "lib/RayMath.sol";
import {IDEToken} from "./interfaces/IDEToken.sol";
import {IPool} from "./interfaces/IPool.sol";
import {IController} from "./interfaces/IController.sol";

contract DEToken is IDEToken, ERC20, ReentrancyGuard, Ownable, Initializable {
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

        lastActionTimestamp[msg.sender] = block.timestamp;
    }

    modifier noDebt(address user_) {
        IController controller = pool.controller();

        if (controller.healthFactorFor(user_) < type(uint256).max) {
            revert DebtExists(controller.totalDebtOfInUSD(user_));
        }

        _;
    }

    constructor(string memory name_, string memory symbol_, address pool_, address owner_, address externalOwner_)
        ERC20(name_, symbol_)
        Ownable(owner_)
    {
        pool = IPool(pool_);
        lastYieldUpdate = block.timestamp;

        externalOwner = externalOwner_;
    }

    function initialize() public override initializer {}

    function balanceOf(address account_) public view override(ERC20, IERC20) returns (uint256) {
        return super.balanceOf(account_) + _getInterestEarnedByAUser(account_);
    }

    function transfer(address to_, uint256 value_)
        public
        override(ERC20, IERC20)
        nonReentrant
        mintInterest(msg.sender)
        noDebt(msg.sender)
        returns (bool)
    {
        return super.transfer(to_, value_);
    }

    function transferFrom(address from_, address to_, uint256 value_)
        public
        override(ERC20, IERC20)
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

        if (lastAction > lastPoolUpdate) {
            return 0;
        }

        uint256 timeElapsed = lastPoolUpdate - lastAction;
        uint256 interestEarned = (balance * pool.interestRatePerSecond() * timeElapsed) / RayMath.RAY;

        return interestEarned;
    }
}
