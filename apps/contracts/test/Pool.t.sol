// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import {Test, console} from "forge-std/Test.sol";
import {MockERC20} from "../src/mocks/MockERC20.sol";
import {Pool} from "../src/Pool.sol";

contract PoolTest is Test {
    address deployer;
    address owner;
    address alice;
    address bob;

    MockERC20 token;
    Pool pool;
    address deTokenAddress;
    uint256 interestRate;

    function setUp() public {
        interestRate = 0.1 * 1e27;

        deployer = vm.addr(0xBEEF);
        owner = vm.addr(0xB055);
        alice = vm.addr(0xA11CE);
        bob = vm.addr(0xB0B);

        vm.startPrank(deployer);
        token = new MockERC20("MockToken", "MTK");
        pool = new Pool(address(token), interestRate, deployer, owner); // 10% -> 0.10 -> to Ray -> 0.1 * 1e27 -> 1e26
        deTokenAddress = address(pool.deToken());

        token.transfer(alice, 1000 * 1e18);
        token.transfer(bob, 1000 * 1e18);
        vm.stopPrank();

        vm.prank(owner);
        token.approve(address(pool), type(uint256).max);

        vm.prank(alice);
        token.approve(address(pool), type(uint256).max);

        vm.prank(bob);
        token.approve(address(pool), type(uint256).max);
    }

    function test_name() public view {
        assertEq(IERC20Metadata(deTokenAddress).name(), "deSync MockToken");
    }

    function test_symbol() public view {
        assertEq(IERC20Metadata(deTokenAddress).symbol(), "deMTK");
    }

    function test_deposit() public {
        vm.prank(alice);
        pool.deposit(100);

        assertEq(IERC20(deTokenAddress).balanceOf(alice), 100);
    }

    function test_depositMore() public {
        vm.startPrank(alice);
        pool.deposit(100);
        pool.deposit(200);
        vm.stopPrank();

        assertEq(IERC20(deTokenAddress).balanceOf(alice), 300);
    }

    function test_depositMoreAfterTimeElapsed() public {
        vm.startPrank(alice);
        pool.deposit(100 * 1e18);

        vm.warp(block.timestamp + 1 days);

        uint256 interestPerSecond = interestRate / 365 days;
        uint256 collectedInterest = 1 days * interestPerSecond * 100 * 1e18 / 1e27;

        pool.deposit(200 * 1e18);
        vm.stopPrank();

        assertEq(IERC20(deTokenAddress).balanceOf(alice), 300 * 1e18 + collectedInterest);
    }

    function test_depositMoreAfterTimeElapsedTwice() public {
        vm.startPrank(alice);
        pool.deposit(100 * 1e18);

        vm.warp(block.timestamp + 1 days);

        uint256 interestPerSecond = interestRate / 365 days;
        uint256 collectedInterest = 1 days * interestPerSecond * 100 * 1e18 / 1e27;

        pool.deposit(200 * 1e18);

        vm.warp(block.timestamp + 1 days);

        uint256 collectedInterest2 = 1 days * interestPerSecond * 300 * 1e18 / 1e27;

        pool.deposit(400 * 1e18);
        vm.stopPrank();

        assertGt(IERC20(deTokenAddress).balanceOf(alice), 700 * 1e18 + collectedInterest + collectedInterest2);
    }

    function test_unlockAmountStep1() public {
        vm.startPrank(alice);
        pool.deposit(100);

        pool.unlock(50);
        vm.stopPrank();

        assertEq(IERC20(deTokenAddress).balanceOf(alice), 50);
        assertEq(pool.unlocked(alice), 0);
    }

    function test_unlockAmountStep2() public {
        vm.startPrank(alice);
        pool.deposit(100);

        pool.unlock(50);
        vm.stopPrank();

        vm.warp(block.timestamp + 1 days);

        vm.prank(owner);
        pool._unlock(alice, 50);

        assertEq(IERC20(deTokenAddress).balanceOf(alice), 50);
        assertEq(pool.unlocked(alice), 50);
    }

    function test_withdrawWithoutUnlockedReverts() public {
        vm.prank(alice);
        vm.expectRevert();
        pool.withdraw();
    }

    function test_withdrawTransfersTokensCorrectly() public {
        vm.startPrank(alice);
        pool.deposit(100 * 1e18);
        pool.unlock(50 * 1e18);
        vm.stopPrank();

        vm.prank(owner);
        pool._unlock(alice, 50 * 1e18);

        uint256 balanceBefore = token.balanceOf(alice);
        vm.prank(alice);
        pool.withdraw();
        uint256 balanceAfter = token.balanceOf(alice);

        assertEq(balanceAfter - balanceBefore, 50 * 1e18);
        assertEq(pool.unlocked(alice), 0);
    }

    function test_onlyController_canBorrow() public {
        vm.prank(alice);
        vm.expectRevert();
        pool._borrow(alice, 10 * 1e18);
    }

    function test_borrowAndRepay() public {
        vm.startPrank(alice);
        pool.deposit(200 * 1e18);
        vm.stopPrank();

        vm.prank(deployer);
        pool._borrow(alice, 50 * 1e18);
        uint256 debt = pool.debtOf(alice);
        assertEq(debt, 50 * 1e18);

        vm.prank(alice);
        pool.repay(address(token), 20 * 1e18);
        uint256 newDebt = pool.debtOf(alice);
        assertEq(newDebt, 30 * 1e18);
    }

    function test_onlyController_canLiquidate() public {
        vm.startPrank(alice);
        pool.deposit(100 * 1e18);
        pool.unlock(50 * 1e18);
        vm.stopPrank();

        vm.prank(owner);
        pool._unlock(alice, 50 * 1e18);

        vm.prank(deployer);
        pool._borrow(alice, 30 * 1e18);

        vm.prank(alice);
        vm.expectRevert();
        pool._liquidate(alice, alice);
    }

    function test_liquidateTransfersCollateral() public {
        vm.startPrank(alice);
        pool.deposit(100 * 1e18);
        vm.stopPrank();

        vm.prank(deployer);
        pool._borrow(alice, 40 * 1e18);

        vm.prank(deployer);
        pool._liquidate(alice, bob);

        assertEq(pool.debtOf(alice), 0);
        assertEq(IERC20(deTokenAddress).balanceOf(alice), 0);

        assertEq(IERC20(deTokenAddress).balanceOf(bob), 100 * 1e18);
    }

    function test_updateLiquidityIndexIncreases() public {
        uint256 initialIndex = pool.liquidityIndex();
        vm.warp(block.timestamp + 1 days);
        pool.updateLiquidityIndex();
        uint256 newIndex = pool.liquidityIndex();
        assertGt(newIndex, initialIndex);
    }

    function test_multipleUnlocksAccumulate() public {
        vm.startPrank(alice);
        pool.deposit(200);
        pool.unlock(50);
        pool.unlock(30);
        vm.stopPrank();

        vm.prank(owner);
        pool._unlock(alice, 80);
        assertEq(pool.unlocked(alice), 80);
        assertEq(IERC20(deTokenAddress).balanceOf(alice), 120);
    }

    function test_insufficientUnlockIntentReverts() public {
        vm.startPrank(alice);
        pool.deposit(100);
        pool.unlock(40);
        vm.stopPrank();

        vm.prank(owner);
        vm.expectRevert();
        pool._unlock(alice, 50);
    }

    function test_repayWithoutDebtReverts() public {
        vm.prank(alice);
        vm.expectRevert();
        pool.repay(address(token), 10 * 1e18);
    }

    function test_collateralAndDebtViews() public {
        vm.startPrank(alice);
        pool.deposit(150 * 1e18);
        pool.unlock(50 * 1e18);
        vm.stopPrank();

        uint256 collateral = pool.collateralOf(alice);
        assertEq(collateral, 100 * 1e18);

        vm.prank(deployer);
        pool._borrow(alice, 30 * 1e18);
        uint256 debt = pool.debtOf(alice);
        assertEq(debt, 30 * 1e18);
    }

    function testFuzzDeposit(uint256 depositAmount) public {
        vm.assume(depositAmount > 0 && depositAmount <= 1000 * 1e18);
        vm.prank(alice);
        pool.deposit(depositAmount);
        uint256 collateral = pool.collateralOf(alice);
        assertEq(collateral, depositAmount);
    }

    function testFuzzUnlock(uint256 depositAmount, uint256 unlockAmount) public {
        vm.assume(depositAmount > 0 && depositAmount <= 1000 * 1e18);
        vm.assume(unlockAmount <= depositAmount);

        vm.startPrank(alice);
        pool.deposit(depositAmount);
        pool.unlock(unlockAmount);
        vm.stopPrank();

        uint256 deTokenBalance = IERC20(deTokenAddress).balanceOf(alice);
        assertEq(deTokenBalance, depositAmount - unlockAmount);

        uint256 intent = pool.unlockIntents(alice);
        assertEq(intent, unlockAmount);
    }
}
