// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import {Test} from "forge-std/Test.sol";
import {MockERC20} from "src/mocks/MockERC20.sol";
import {IPool} from "src/interfaces/IPool.sol";
import {Stratergy1Pool} from "src/Stratergy1Pool.sol";

contract PoolTest is Test {
    address deployer;
    address owner;
    address alice;
    address bob;

    MockERC20 token;
    IPool pool;
    address deTokenAddress;
    uint256 interestRate;

    function setUp() public {
        deployer = vm.addr(69420);
        owner = vm.addr(42069);
        alice = vm.addr(69);
        bob = vm.addr(420);

        interestRate = 0.1 * 1e27;

        vm.startPrank(deployer);
        token = new MockERC20("MockToken", "MTK");
        pool = new Stratergy1Pool(address(token), interestRate, deployer, owner); // 10% -> 0.10 -> to Ray -> 0.1 * 1e27 -> 1e26
        deTokenAddress = address(pool.deToken());

        token.transfer(alice, 1000 * 1e18);
        token.transfer(bob, 1000 * 1e18);
        token.transfer(address(pool), 1000 * 1e18);
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
        pool.updateLiquidityIndex();

        uint256 interestPerSecond = interestRate / 365 days;
        uint256 collectedInterest = 1 days * interestPerSecond * 100 * 1e18 / 1e27;

        pool.deposit(200 * 1e18);

        vm.warp(block.timestamp + 1 days);
        pool.updateLiquidityIndex();

        uint256 intermediateTotal = 100 * 1e18 + collectedInterest + 200 * 1e18;
        uint256 collectedInterest2 = 1 days * interestPerSecond * intermediateTotal / 1e27;

        pool.deposit(400 * 1e18);
        vm.stopPrank();

        /* Expected final balance is the sum of:
         - Deposits: 100 + 200 + 400 = 700 tokens,
         - Plus the interest accrued over both periods. */
        uint256 expectedFinal = (700 * 1e18 + collectedInterest + collectedInterest2) + 1;

        assertEq(IERC20(deTokenAddress).balanceOf(alice), expectedFinal);
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

    function testFuzzWithdraw(uint256 depositAmount, uint256 unlockAmount) public {
        vm.assume(depositAmount > 0 && depositAmount <= 1000 * 1e18);
        vm.assume(unlockAmount > 0 && unlockAmount <= depositAmount);

        uint256 initialBalance = token.balanceOf(alice);

        vm.startPrank(alice);
        pool.deposit(depositAmount);
        pool.unlock(unlockAmount);
        vm.stopPrank();

        vm.prank(owner);
        pool._unlock(alice, unlockAmount);

        vm.prank(alice);
        pool.withdraw();

        uint256 finalBalance = token.balanceOf(alice);

        assertEq(finalBalance, initialBalance - (depositAmount - unlockAmount));
        assertEq(pool.unlocked(alice), 0);
    }

    function testFuzzBorrowAndRepay(uint256 borrowAmount, uint256 repayAmount) public {
        vm.assume(borrowAmount > 0 && borrowAmount <= 1000 * 1e18);
        vm.assume(repayAmount <= borrowAmount);

        vm.prank(deployer);
        pool._borrow(alice, borrowAmount);
        uint256 debt = pool.debtOf(alice);
        assertEq(debt, borrowAmount);

        vm.prank(alice);
        pool.repay(address(token), repayAmount);
        uint256 remainingDebt = pool.debtOf(alice);
        assertEq(remainingDebt, borrowAmount - repayAmount);
    }

    function testFuzzUpdateLiquidityIndex(uint256 timeWarp) public {
        vm.assume(timeWarp > 0 && timeWarp < 365 days);

        uint256 initialIndex = pool.liquidityIndex();
        vm.warp(block.timestamp + timeWarp);
        pool.updateLiquidityIndex();
        uint256 newIndex = pool.liquidityIndex();
        assertGt(newIndex, initialIndex);
    }

    function testFuzzInsufficientUnlock(uint256 depositAmount, uint256 unlockAmount, uint256 extra) public {
        vm.assume(depositAmount > 0 && depositAmount <= 1000 * 1e18);
        vm.assume(unlockAmount <= depositAmount);
        vm.assume(extra > 0);

        vm.startPrank(alice);
        pool.deposit(depositAmount);
        pool.unlock(unlockAmount);
        vm.stopPrank();

        vm.prank(owner);
        vm.expectRevert();
        pool._unlock(alice, unlockAmount + extra);
    }

    function testFuzzLiquidation(uint256 depositAmount, uint256 borrowAmount) public {
        vm.assume(depositAmount > 0 && depositAmount <= 1000 * 1e18);
        vm.assume(borrowAmount > 0 && borrowAmount <= 1000 * 1e18);

        vm.prank(alice);
        pool.deposit(depositAmount);

        vm.prank(deployer);
        pool._borrow(alice, borrowAmount);

        uint256 bobInitialBalance = IERC20(deTokenAddress).balanceOf(bob);

        vm.prank(deployer);
        pool._liquidate(alice, bob);

        assertEq(IERC20(deTokenAddress).balanceOf(alice), 0);
        assertEq(pool.debtOf(alice), 0);

        uint256 bobFinalBalance = IERC20(deTokenAddress).balanceOf(bob);
        assertEq(bobFinalBalance, bobInitialBalance + depositAmount);
    }
}
