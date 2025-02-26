// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {StratergyPool} from "src/StratergyPool.sol";
import {IDEToken} from "src/interfaces/IDEToken.sol";
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
            interestRate, // 10% -> 0.10 -> to Ray -> 0.1 * 1e27 -> 1e26
            deployer,
            owner,
            address(usdc),
            ammPoolFee,
            address(nonFungiblePositionManager),
            address(swapRouter),
            address(futuresMarket)
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

        vm.prank(owner);
        pool.executeStratergy();

        skip(1 days);

        vm.startPrank(owner);
        pool.unexecuteStratergy();
        deToken.updateYieldDaily();
        vm.stopPrank();

        uint256 interestRatePerSecond = pool.interestRatePerSecond();
        uint256 collectedInterest = 100 * 1e18 * interestRatePerSecond * 1 days / 1e27;

        vm.prank(alice);
        pool.deposit(100 * 1e18);

        // assertEq(eth.balanceOf(address(pool)), 1200 * 1e18);
        assertEq(deToken.balanceOf(alice), 200 * 1e18 + collectedInterest);
    }
}
