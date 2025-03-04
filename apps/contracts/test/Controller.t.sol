// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {Controller} from "src/Controller.sol";
import {StratergyPool} from "src/StratergyPool.sol";
import {IDEToken} from "src/interfaces/IDEToken.sol";
import {IDebtToken} from "src/interfaces/IDebtToken.sol";
import {MockMintableERC20} from "src/mocks/MockMintableERC20.sol";
import {MockAggregatorV3} from "src/mocks/MockAggregatorV3.sol";
import {MockNonFungiblePositionManager} from "src/mocks/MockNonFungiblePositionManager.sol";
import {MockAggregatorV3} from "src/mocks/MockAggregatorV3.sol";
import {MockSwapRouter} from "src/mocks/MockSwapRouter.sol";
import {MockFuturesMarket} from "src/mocks/MockFuturesMarket.sol";

contract ControllerTest is Test {
    address superDeployer;
    address deployer;
    address owner;
    address alice;
    address bob;

    MockMintableERC20 eth;
    MockMintableERC20 btc;
    MockMintableERC20 usdc;

    MockNonFungiblePositionManager nonFungiblePositionManager;
    MockSwapRouter swapRouter;
    MockFuturesMarket futuresMarket;

    StratergyPool ethPool;
    StratergyPool btcPool;

    IDEToken ethDEToken;
    IDEToken btcDEToken;

    IDebtToken ethDebtToken;
    IDebtToken btcDebtToken;

    uint256 liquidationThreshold;
    uint256 interestRate;
    uint24 ammPoolFee;

    Controller controller;

    mapping(MockMintableERC20 => MockAggregatorV3) priceFeeds;

    function setUp() public {
        superDeployer = vm.addr(42);
        deployer = vm.addr(69420);
        owner = vm.addr(42069);
        alice = vm.addr(69);
        bob = vm.addr(420);

        liquidationThreshold = 0.95 * 1e27; // 95% -> 0.95 -> to Ray -> 0.95 * 1e27 -> 1e26
        interestRate = 0.1 * 1e27; // 10% -> 0.10 -> to Ray -> 0.1 * 1e27 -> 1e26
        ammPoolFee = 0;

        vm.startPrank(superDeployer);
        eth = new MockMintableERC20("Ether", "ETH", 1 * 1e18, owner);
        btc = new MockMintableERC20("Bitcoin", "BTC", 0.05 * 1e18, owner);
        usdc = new MockMintableERC20("USD Coin", "USDC", 4000 * 1e18, owner);

        priceFeeds[eth] = new MockAggregatorV3(3000 * 1e18, 18, owner);
        priceFeeds[btc] = new MockAggregatorV3(95000 * 1e9, 9, owner);
        priceFeeds[usdc] = new MockAggregatorV3(1 * 1e6, 6, owner);

        nonFungiblePositionManager = new MockNonFungiblePositionManager(interestRate, owner);

        address[] memory _tokens = new address[](3);
        _tokens[0] = address(eth);
        _tokens[1] = address(btc);
        _tokens[2] = address(usdc);

        address[] memory _priceFeeds = new address[](3);
        _priceFeeds[0] = address(priceFeeds[eth]);
        _priceFeeds[1] = address(priceFeeds[btc]);
        _priceFeeds[2] = address(priceFeeds[usdc]);

        swapRouter = new MockSwapRouter(_tokens, _priceFeeds, owner);
        futuresMarket = new MockFuturesMarket(_tokens, _priceFeeds, owner);
        vm.stopPrank();

        vm.startPrank(deployer);
        controller = new Controller(liquidationThreshold, owner);

        ethPool = new StratergyPool(
            address(eth),
            address(controller),
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
        address btcPoolAddress = controller.createStartergyPool(
            address(btc),
            address(usdc),
            ammPoolFee,
            address(nonFungiblePositionManager),
            address(swapRouter),
            address(futuresMarket),
            address(priceFeeds[btc]),
            owner
        );
        btcPool = StratergyPool(btcPoolAddress);

        controller.addPool(address(ethPool));
        vm.stopPrank();

        ethDEToken = IDEToken(ethPool.deToken());
        btcDEToken = IDEToken(btcPool.deToken());

        ethDebtToken = IDebtToken(ethPool.debtToken());
        btcDebtToken = IDebtToken(btcPool.debtToken());

        vm.startPrank(owner);
        eth._addMinterBurner(address(swapRouter));
        btc._addMinterBurner(address(swapRouter));
        usdc._addMinterBurner(address(swapRouter));
        eth._addMinterBurner(address(nonFungiblePositionManager));
        btc._addMinterBurner(address(nonFungiblePositionManager));
        usdc._addMinterBurner(address(nonFungiblePositionManager));
        eth._addMinterBurner(address(futuresMarket));
        btc._addMinterBurner(address(futuresMarket));
        usdc._addMinterBurner(address(futuresMarket));

        futuresMarket._addAuthorized(address(ethPool));
        futuresMarket._addAuthorized(address(btcPool));

        eth._addMinterBurner(owner);
        btc._addMinterBurner(owner);
        eth._mint_(alice, 1000 * 1e18);
        btc._mint_(alice, 1000 * 1e18);
        eth._mint_(bob, 1000 * 1e18);
        btc._mint_(bob, 1000 * 1e18);
        eth._mint_(address(ethPool), 100000 * 1e18);
        btc._mint_(address(btcPool), 1000 * 1e18);
        vm.stopPrank();

        vm.startPrank(alice);
        eth.approve(address(ethPool), 1000 * 1e18);
        btc.approve(address(btcPool), 1000 * 1e18);
        vm.stopPrank();

        vm.startPrank(bob);
        eth.approve(address(ethPool), 1000 * 1e18);
        btc.approve(address(btcPool), 1000 * 1e18);
        vm.stopPrank();

        skip(1 days);
    }

    function test_createStratergyPoolWorks() public view {
        assertEq(controller.poolFor(address(btc)), address(btcPool));
        assertEq(btcPool.owner(), owner);
        assertEq(address(btcPool.token()), address(btc));
        assertEq(address(btcPool.controller()), address(controller));
    }

    function test_addPoolWorks() public view {
        assertEq(controller.poolFor(address(eth)), address(ethPool));
        assertEq(ethPool.owner(), owner);
        assertEq(address(ethPool.token()), address(eth));
        assertEq(address(ethPool.controller()), address(controller));
    }

    function test_removePoolWorks() public {
        vm.prank(owner);
        controller.removePool(address(eth));
        assertEq(controller.poolFor(address(eth)), address(0));
    }

    function test_nonOwnerCannotRemovePool() public {
        vm.prank(alice);
        vm.expectRevert();
        controller.removePool(address(eth));
    }

    function test_nonOwnerCannotAddPool() public {
        vm.prank(alice);
        vm.expectRevert();
        controller.addPool(address(1));
    }

    function test_nonOwnerCannotCreateStratergyPool() public {
        vm.prank(alice);
        vm.expectRevert();
        controller.createStartergyPool(
            address(usdc),
            address(usdc),
            ammPoolFee,
            address(nonFungiblePositionManager),
            address(swapRouter),
            address(futuresMarket),
            address(priceFeeds[usdc]),
            owner
        );
    }

    function test_borrowWithoutCollateral() public {
        vm.prank(alice);
        vm.expectRevert();
        controller.borrow(address(eth), 25 * 1e18);
    }

    function test_borrow() public {
        vm.startPrank(alice);
        btcPool.deposit(1 * 1e18);

        controller.borrow(address(eth), 10 * 1e18);
        vm.stopPrank();

        assertEq(ethPool.debtOf(alice), 10 * 1e18);
    }

    function test_borrowMoreThanCollateral() public {
        vm.startPrank(alice);
        btcPool.deposit(1 * 1e18);

        vm.expectRevert();
        controller.borrow(address(eth), 100 * 1e18);
    }

    function test_liquidateBeforeThreshold() public {
        vm.startPrank(alice);
        btcPool.deposit(1 * 1e18);
        controller.borrow(address(eth), 10 * 1e18);
        vm.stopPrank();

        vm.prank(bob);
        vm.expectRevert();
        controller.liquidate(alice);
    }

    function test_liquidateOnPriceMovement() public {
        vm.startPrank(alice);
        btcPool.deposit(1 * 1e18);
        controller.borrow(address(eth), 10 * 1e18);
        vm.stopPrank();

        vm.prank(owner);
        priceFeeds[eth].setPrice(20000 * 1e18);

        vm.prank(bob);
        controller.liquidate(alice);
    }

    function test_defaultHealthFactor() public {
        vm.prank(alice);
        ethPool.deposit(100 * 1e18);

        assertEq(controller.healthFactorFor(alice), type(uint256).max);
    }

    function test_healthFactor() public {
        vm.startPrank(alice);
        ethPool.deposit(100 * 1e18);
        controller.borrow(address(eth), 50 * 1e18);
        vm.stopPrank();

        assertEq(controller.healthFactorFor(alice), 19 * 1e26);
    }

    function test_healthFactorBelowThreshold() public {
        vm.startPrank(alice);
        btcPool.deposit(1 * 1e18);
        controller.borrow(address(eth), 10 * 1e18);
        vm.stopPrank();

        vm.prank(owner);
        priceFeeds[eth].setPrice(10000 * 1e18);

        assertLt(controller.healthFactorFor(alice), 1e27);
    }

    function test_transferDETokensWhenYouHaveDebt() public {
        vm.startPrank(alice);
        btcPool.deposit(1 * 1e18);
        controller.borrow(address(eth), 10 * 1e18);

        vm.expectRevert();
        ethDEToken.transfer(bob, 5 * 1e18);
        vm.stopPrank();
    }

    function test_transferDETokens() public {
        vm.startPrank(alice);
        ethPool.deposit(100 * 1e18);
        ethDEToken.transfer(bob, 5 * 1e18);
        vm.stopPrank();

        assertEq(ethDEToken.balanceOf(bob), 5 * 1e18);
        assertEq(ethDEToken.balanceOf(alice), 95 * 1e18);
    }
}
