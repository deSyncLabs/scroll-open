// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import {Test, console} from "forge-std/Test.sol";
import {MockERC20} from "../src/mocks/MockERC20.sol";
import {Pool} from "../src/Pool.sol";

contract PoolTest is Test {
    MockERC20 public token;
    Pool public pool;
    address public deTokenAddress;
    uint256 interestRate;

    function setUp() public {
        interestRate = 0.1 * 1e27;

        token = new MockERC20("MockToken", "MTK");
        pool = new Pool(address(token), interestRate); // 10% -> 0.10 -> to Ray -> 0.1 * 1e27 -> 1e26
        deTokenAddress = address(pool.deToken());
    }

    function test_name() public view {
        assertEq(IERC20Metadata(deTokenAddress).name(), "deSync MockToken");
    }

    function test_symbol() public view {
        assertEq(IERC20Metadata(deTokenAddress).symbol(), "deMTK");
    }

    function test_deposit() public {
        pool.deposit(100);

        assertEq(IERC20(deTokenAddress).balanceOf(address(this)), 100);
    }

    function test_depositMore() public {
        pool.deposit(100);
        pool.deposit(200);

        assertEq(IERC20(deTokenAddress).balanceOf(address(this)), 300);
    }

    function test_depositMoreAfterTimeElapsed() public {
        pool.deposit(100 * 1e18);

        vm.warp(block.timestamp + 1 days);

        uint256 interestPerSecond = interestRate / 365 days;
        uint256 collectedInterest = 1 days * interestPerSecond * 100 * 1e18 / 1e27;

        pool.deposit(200 * 1e18);

        assertEq(IERC20(deTokenAddress).balanceOf(address(this)), 300 * 1e18 + collectedInterest);
    }
}
