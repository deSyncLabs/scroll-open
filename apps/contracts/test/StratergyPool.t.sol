// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {StratergyPool} from "src/StratergyPool.sol";
import {IDEToken} from "src/interfaces/IDEToken.sol";
import {IDebtToken} from "src/interfaces/IDebtToken.sol";
import {MockMintableERC20} from "src/mocks/MockMintableERC20.sol";
import {MockNonFungiblePositionManager} from "src/mocks/MockNonFungiblePositionManager.sol";
import {MockAggregatorV3} from "src/mocks/MockAggregatorV3.sol";
import {MockSwapRouter} from "src/mocks/MockSwapRouter.sol";
import {MockFuturesMarket} from "src/mocks/MockFuturesMarket.sol";

contract StratergyPoolTest is Test {
    address superDeployer;
    address deployer;
    address owner;
    address alice;
    address bob;

    MockMintableERC20 eth;
    MockMintableERC20 usdc;
    MockNonFungiblePositionManager nonFungiblePositionManager;
    MockSwapRouter swapRouter;
    MockFuturesMarket futuresMarket;

    mapping(MockMintableERC20 => MockAggregatorV3) priceFeeds;

    StratergyPool pool;

    IDEToken deToken;
    IDebtToken debtToken;
    uint256 interestRate;
    uint24 ammPoolFee;

    function setUp() public {
        superDeployer = vm.addr(42);
        deployer = vm.addr(69420);
        owner = vm.addr(42069);
        alice = vm.addr(69);
        bob = vm.addr(420);

        interestRate = 0.1 * 1e27; // 10% -> 0.10 -> to Ray -> 0.1 * 1e27 -> 1e26
        ammPoolFee = 0;

        vm.startPrank(superDeployer);
        eth = new MockMintableERC20("Ethereum", "ETH", 100 * 1e18, owner);
        usdc = new MockMintableERC20("USD Coin", "USDC", 0, owner);

        nonFungiblePositionManager = new MockNonFungiblePositionManager(interestRate, owner);

        priceFeeds[eth] = new MockAggregatorV3(3000 * 1e18, 18, owner);
        priceFeeds[usdc] = new MockAggregatorV3(1 * 1e6, 6, owner);

        address[] memory _tokens = new address[](2);
        _tokens[0] = address(eth);
        _tokens[1] = address(usdc);

        address[] memory _priceFeeds = new address[](2);
        _priceFeeds[0] = address(priceFeeds[eth]);
        _priceFeeds[1] = address(priceFeeds[usdc]);

        swapRouter = new MockSwapRouter(_tokens, _priceFeeds, owner);
        futuresMarket = new MockFuturesMarket(_tokens, _priceFeeds, owner);
        vm.stopPrank();

        vm.startPrank(deployer);
        pool = new StratergyPool(
            address(eth),
            deployer,
            owner,
            address(usdc),
            ammPoolFee,
            address(nonFungiblePositionManager),
            address(swapRouter),
            address(futuresMarket),
            address(priceFeeds[eth])
        );
        vm.stopPrank();

        vm.startPrank(owner);
        eth._addMinterBurner(address(swapRouter));
        usdc._addMinterBurner(address(swapRouter));
        eth._addMinterBurner(address(nonFungiblePositionManager));
        usdc._addMinterBurner(address(nonFungiblePositionManager));
        eth._addMinterBurner(address(futuresMarket));
        usdc._addMinterBurner(address(futuresMarket));

        futuresMarket._addAuthorized(address(pool));

        eth._addMinterBurner(owner);
        eth._mint_(alice, 1000 * 1e18);
        eth._mint_(bob, 1000 * 1e18);
        eth._mint_(address(pool), 1000 * 1e18);
        vm.stopPrank();

        deToken = IDEToken(pool.deToken());
        debtToken = IDebtToken(pool.debtToken());

        vm.prank(alice);
        eth.approve(address(pool), 1000 * 1e18);

        vm.prank(bob);
        eth.approve(address(pool), 1000 * 1e18);

        skip(10 days);
    }

    function test_name() public view {
        assertEq(deToken.name(), "deSync Ethereum");
    }

    function test_symbol() public view {
        assertEq(deToken.symbol(), "deETH");
    }

    function test_deposit() public {
        vm.prank(alice);
        pool.deposit(100 * 1e18);

        assertEq(eth.balanceOf(address(pool)), 1100 * 1e18);
        assertEq(deToken.balanceOf(alice), 100 * 1e18);
    }

    function test_depositTwice() public {
        vm.startPrank(alice);
        pool.deposit(100 * 1e18);
        pool.deposit(100 * 1e18);
        vm.stopPrank();

        assertEq(eth.balanceOf(address(pool)), 1200 * 1e18);
        assertEq(deToken.balanceOf(alice), 200 * 1e18);
    }

    function test_depositTwiceAfterADayWithoutStratergy() public {
        vm.prank(alice);
        pool.deposit(100 * 1e18);

        skip(1 days);

        vm.startPrank(alice);
        pool.deposit(100 * 1e18);

        assertEq(eth.balanceOf(address(pool)), 1200 * 1e18);
        assertEq(deToken.balanceOf(alice), 200 * 1e18);
    }

    function test_depositTwiceAfterADayWithStratergy() public {
        vm.prank(alice);
        pool.deposit(100 * 1e18);

        uint256 lastUpdateTimestamp = pool.lastUpdateTimestamp();

        vm.prank(owner);
        pool.executeStratergy();

        skip(1 days);

        vm.startPrank(owner);
        pool.unexecuteStratergy();
        vm.stopPrank();

        uint256 timeElapsedPool = block.timestamp - lastUpdateTimestamp;
        uint256 timeElapsedAlice = lastUpdateTimestamp - deToken.lastActionTimestamp(alice);
        uint256 interestRatePerSecond = pool.interestRatePerSecond();
        uint256 interestCollectedPool = (1100 * 1e18 * interestRatePerSecond * timeElapsedPool / 1e27) + 1;
        uint256 collectedInterestAlice = (100 * 1e18 * interestRatePerSecond * timeElapsedAlice) / 1e27;

        vm.prank(alice);
        pool.deposit(100 * 1e18);

        assertEq(eth.balanceOf(address(pool)), 1200 * 1e18 + interestCollectedPool);
        assertGt(deToken.balanceOf(alice), 200 * 1e18 + collectedInterestAlice);
    }

    function test_sendUnlockIntent() public {
        vm.prank(alice);
        pool.deposit(100 * 1e18);

        vm.prank(owner);
        pool.executeStratergy();

        skip(2 hours);

        vm.startPrank(alice);
        pool.unlock(25 * 1e18);

        assertEq(deToken.balanceOf(alice), 75 * 1e18);
        assertEq(pool.unlockIntents(alice), 25 * 1e18);
    }

    function test_sendUnlockIntentTwice() public {
        vm.prank(alice);
        pool.deposit(100 * 1e18);

        vm.prank(owner);
        pool.executeStratergy();

        skip(2 hours);

        vm.startPrank(alice);
        pool.unlock(25 * 1e18);
        pool.unlock(25 * 1e18);

        assertEq(deToken.balanceOf(alice), 50 * 1e18);
        assertEq(pool.unlockIntents(alice), 50 * 1e18);
    }

    function test_verifyLockedPoolWhenExecutingStratergy() public {
        vm.prank(alice);
        pool.deposit(100 * 1e18);

        vm.prank(owner);
        pool.executeStratergy();

        assert(pool.locked());
    }

    function test_verifyUnlockedPoolWhenUnexecutedStratergy() public {
        vm.prank(alice);
        pool.deposit(100 * 1e18);

        vm.prank(owner);
        pool.executeStratergy();

        skip(2 hours);

        vm.prank(owner);
        pool.unexecuteStratergy();

        assert(!pool.locked());
    }

    function test_cannotWithdrawWithoutAnIntent() public {
        vm.prank(alice);
        pool.deposit(100 * 1e18);

        vm.prank(owner);
        pool.executeStratergy();

        skip(2 hours);

        vm.prank(owner);
        pool.unexecuteStratergy();

        vm.prank(alice);
        vm.expectRevert();
        pool.withdraw();
    }

    function test_cannotWithdrawBeforeEndOfTheStratergyCycle() public {
        vm.prank(alice);
        pool.deposit(100 * 1e18);

        vm.prank(owner);
        pool.executeStratergy();

        skip(1 hours);

        vm.startPrank(alice);
        pool.unlock(25 * 1e18);

        vm.expectRevert();
        pool.withdraw();
        vm.stopPrank();
    }

    function test_allowWithdrawAfterEndOfTheStratergyCycle() public {
        vm.prank(alice);
        pool.deposit(100 * 1e18);

        vm.prank(owner);
        pool.executeStratergy();

        skip(2 hours);

        vm.prank(alice);
        pool.unlock(25 * 1e18);

        vm.prank(owner);
        pool.unexecuteStratergy();

        vm.prank(alice);
        pool.withdraw();

        assertLt(deToken.balanceOf(alice), 100 * 1e18);
        assertEq(pool.unlockIntents(alice), 0);
    }

    function test_allowWithdrawalInNextCycleIfUnlocked() public {
        vm.prank(alice);
        pool.deposit(100 * 1e18);

        vm.prank(owner);
        pool.executeStratergy();

        skip(2 hours);

        vm.prank(alice);
        pool.unlock(25 * 1e18);

        vm.prank(owner);
        pool.unexecuteStratergy();

        skip(10 minutes);

        vm.prank(alice);
        pool.unlock(50 * 1e18);

        vm.prank(owner);
        pool.executeStratergy();

        assertLt(deToken.balanceOf(alice), 100 * 1e18);
        assertEq(pool.unlockIntents(alice), 50 * 1e18);
        assertEq(eth.balanceOf(alice), ((1000 - 100) + 25) * 1e18);
    }

    function test_allowWithdrawalInNextCycleIfUnlockedTwice() public {
        vm.prank(alice);
        pool.deposit(250 * 1e18);

        vm.prank(owner);
        pool.executeStratergy();

        skip(2 hours);

        vm.prank(alice);
        pool.unlock(25 * 1e18);

        vm.prank(owner);
        pool.unexecuteStratergy();

        skip(10 minutes);

        vm.prank(alice);
        pool.unlock(50 * 1e18);

        vm.prank(owner);
        pool.executeStratergy();

        skip(2 hours);

        vm.prank(owner);
        pool.unexecuteStratergy();

        skip(10 minutes);

        vm.prank(alice);
        pool.unlock(75 * 1e18);

        skip(10 minutes);

        vm.prank(alice);
        pool.unlock(100 * 1e18);

        vm.prank(owner);
        pool.executeStratergy();

        assertLt(deToken.balanceOf(alice), 100 * 1e18);
        assertEq(pool.unlockIntents(alice), 175 * 1e18);
        assertEq(eth.balanceOf(alice), ((1000 - 250) + 25 + 50) * 1e18);
    }

    function test_borrowWithoutIntent() public {
        vm.prank(alice);
        vm.expectRevert();
        pool.borrow();
    }

    function test_subitBorrowIntentNoStratergy() public {
        vm.prank(alice);
        pool.deposit(100 * 1e18);

        vm.prank(deployer);
        pool._borrow(alice, 25 * 1e18);

        assertEq(pool.borrowIntents(alice), 25 * 1e18);
    }

    function test_submitBorrowIntentDuringStratergy() public {
        vm.prank(alice);
        pool.deposit(100 * 1e18);

        vm.prank(owner);
        pool.executeStratergy();

        vm.prank(deployer);
        pool._borrow(alice, 25 * 1e18);

        assertEq(pool.borrowIntents(alice), 25 * 1e18);
    }

    function test_submitMultipleBorrowIntents() public {
        vm.prank(alice);
        pool.deposit(100 * 1e18);

        vm.prank(deployer);
        pool._borrow(alice, 25 * 1e18);

        skip(1 hours);

        vm.prank(owner);
        pool.executeStratergy();

        skip(1 hours);

        vm.prank(deployer);
        pool._borrow(alice, 50 * 1e18);

        assertEq(pool.borrowIntents(alice), 75 * 1e18);
    }

    function test_borrow() public {
        vm.prank(alice);
        pool.deposit(100 * 1e18);

        vm.prank(owner);
        pool.executeStratergy();

        skip(1 hours);

        vm.prank(deployer);
        pool._borrow(alice, 25 * 1e18);

        vm.prank(owner);
        pool.unexecuteStratergy();

        vm.prank(alice);
        pool.borrow();

        assertEq(eth.balanceOf(alice), (1000 - 75) * 1e18);
        assertEq(deToken.balanceOf(alice), 100 * 1e18);
        assertEq(debtToken.balanceOf(alice), 25 * 1e18);
        assertEq(pool.borrowIntents(alice), 0);
    }

    function test_borrowWithDoubleIntent() public {
        vm.prank(alice);
        pool.deposit(100 * 1e18);

        vm.prank(deployer);
        pool._borrow(alice, 25 * 1e18);

        skip(1 hours);

        vm.prank(owner);
        pool.executeStratergy();

        skip(1 hours);

        vm.prank(deployer);
        pool._borrow(alice, 50 * 1e18);

        skip(1 hours);

        vm.prank(owner);
        pool.unexecuteStratergy();

        vm.prank(alice);
        pool.borrow();

        assertEq(eth.balanceOf(alice), (1000 - 25) * 1e18);
        assertEq(deToken.balanceOf(alice), 100 * 1e18);
        assertEq(debtToken.balanceOf(alice), 75 * 1e18);
        assertEq(pool.borrowIntents(alice), 0);
    }

    function test_borrowDuringNextExecution() public {
        vm.prank(alice);
        pool.deposit(100 * 1e18);

        vm.prank(owner);
        pool.executeStratergy();

        skip(1 hours);

        vm.prank(deployer);
        pool._borrow(alice, 25 * 1e18);

        skip(1 hours);

        vm.prank(owner);
        pool.unexecuteStratergy();

        skip(1 hours);

        vm.prank(owner);
        pool.executeStratergy();

        skip(1 hours);

        vm.prank(alice);
        pool.borrow();

        assertEq(eth.balanceOf(alice), (1000 - 75) * 1e18);
        assertEq(deToken.balanceOf(alice), 100 * 1e18);
        assertEq(debtToken.balanceOf(alice), 25 * 1e18);
        assertEq(pool.borrowIntents(alice), 0);
    }

    function test_autoBorrowOnNextIntentIfAvailable() public {
        vm.prank(alice);
        pool.deposit(100 * 1e18);

        vm.prank(owner);
        pool.executeStratergy();

        skip(1 hours);

        vm.prank(deployer);
        pool._borrow(alice, 25 * 1e18);

        skip(1 hours);

        vm.prank(owner);
        pool.unexecuteStratergy();

        skip(1 hours);

        vm.prank(owner);
        pool.executeStratergy();

        skip(1 hours);

        vm.prank(deployer);
        pool._borrow(alice, 50 * 1e18);

        assertEq(eth.balanceOf(alice), (1000 - 75) * 1e18);
        assertEq(deToken.balanceOf(alice), 100 * 1e18);
        assertEq(debtToken.balanceOf(alice), 25 * 1e18);
        assertEq(pool.borrowIntents(alice), 50 * 1e18);
    }

    function test_onlyControllerCanSubmitBorrowIntent() public {
        vm.prank(alice);
        vm.expectRevert();
        pool._borrow(alice, 25 * 1e18);

        vm.prank(owner);
        vm.expectRevert();
        pool._borrow(alice, 25 * 1e18);
    }

    function test_borrowAndRepay() public {
        vm.prank(alice);
        pool.deposit(100 * 1e18);

        vm.prank(owner);
        pool.executeStratergy();

        skip(1 hours);

        vm.prank(deployer);
        pool._borrow(alice, 25 * 1e18);

        vm.prank(owner);
        pool.unexecuteStratergy();

        vm.prank(alice);
        pool.borrow();

        skip(1 hours);

        vm.prank(alice);
        pool.repay(25 * 1e18);

        assertEq(eth.balanceOf(alice), 900 * 1e18);
        assertEq(deToken.balanceOf(alice), 100 * 1e18);
        assertEq(debtToken.balanceOf(alice), 0);
    }

    function test_repayWithoutBorrow() public {
        vm.prank(alice);
        vm.expectRevert();
        pool.repay(25 * 1e18);
    }

    function test_partiallyRepay() public {
        vm.prank(alice);
        pool.deposit(100 * 1e18);

        vm.prank(owner);
        pool.executeStratergy();

        skip(1 hours);

        vm.prank(deployer);
        pool._borrow(alice, 25 * 1e18);

        vm.prank(owner);
        pool.unexecuteStratergy();

        vm.prank(alice);
        pool.borrow();

        skip(1 hours);

        vm.prank(alice);
        pool.repay(10 * 1e18);

        assertEq(eth.balanceOf(alice), 915 * 1e18);
        assertEq(deToken.balanceOf(alice), 100 * 1e18);
        assertEq(debtToken.balanceOf(alice), 15 * 1e18);
    }

    function test_canLiquidate() public {
        vm.prank(alice);
        pool.deposit(100 * 1e18);

        vm.prank(owner);
        pool.executeStratergy();

        skip(1 hours);

        vm.prank(deployer);
        pool._borrow(alice, 25 * 1e18);

        vm.prank(owner);
        pool.unexecuteStratergy();

        vm.prank(alice);
        pool.borrow();

        skip(1 hours);

        vm.prank(deployer);
        pool._liquidate(alice, bob);

        assertEq(eth.balanceOf(bob), (1000 - 25) * 1e18);
        assertEq(deToken.balanceOf(alice), 0);
        assertEq(deToken.balanceOf(bob), 100 * 1e18);
        assertEq(debtToken.balanceOf(alice), 0);
        assertEq(eth.balanceOf(alice), (1000 - 75) * 1e18);
    }

    function test_earnsMoreThanDepositEvenWhenPriceGoesDown() public {
        vm.prank(alice);
        pool.deposit(100 * 1e18);

        vm.prank(owner);
        pool.executeStratergy();

        skip(1 hours);

        vm.prank(owner);
        priceFeeds[eth].setPrice(2000 * 1e18);

        skip(1 hours);

        vm.prank(owner);
        pool.unexecuteStratergy();

        assertGt(deToken.balanceOf(alice), 100 * 1e18);
    }

    function test_earnsMoreThanDepositEvenWhenPriceGoesUp() public {
        vm.prank(alice);
        pool.deposit(100 * 1e18);

        vm.prank(owner);
        pool.executeStratergy();

        skip(1 hours);

        vm.prank(owner);
        priceFeeds[eth].setPrice(4000 * 1e18);

        skip(1 hours);

        vm.prank(owner);
        pool.unexecuteStratergy();

        assertGt(deToken.balanceOf(alice), 100 * 1e18);
    }

    function test_debtOf() public {
        vm.prank(alice);
        pool.deposit(100 * 1e18);

        vm.prank(owner);
        pool.executeStratergy();

        skip(1 hours);

        vm.prank(deployer);
        pool._borrow(alice, 25 * 1e18);

        vm.prank(owner);
        pool.unexecuteStratergy();

        assertEq(pool.debtOf(alice), 25 * 1e18);
    }

    function test_collateralOf() public {
        vm.prank(alice);
        pool.deposit(100 * 1e18);

        assertEq(pool.collateralOf(alice), 100 * 1e18);
    }

    function test_debtOfInUSD() public {
        vm.prank(alice);
        pool.deposit(100 * 1e18);

        vm.prank(owner);
        pool.executeStratergy();

        skip(1 hours);

        vm.prank(deployer);
        pool._borrow(alice, 25 * 1e18);

        vm.prank(owner);
        pool.unexecuteStratergy();

        uint256 inUSD = 25 * 3000 * 1e18;

        assertEq(pool.debtOfInUSD(alice), inUSD);
    }

    function test_collateralOfInUSD() public {
        vm.prank(alice);
        pool.deposit(100 * 1e18);

        uint256 inUSD = 100 * 3000 * 1e18;

        assertEq(pool.collateralOfInUSD(alice), inUSD);
    }
}
