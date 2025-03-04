// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {MockMintableERC20} from "src/mocks/MockMintableERC20.sol";
import {MockNonFungiblePositionManager} from "src/mocks/MockNonFungiblePositionManager.sol";
import {MockSwapRouter} from "src/mocks/MockSwapRouter.sol";
import {MockFuturesMarket} from "src/mocks/MockFuturesMarket.sol";
import {StratergyPool} from "src/StratergyPool.sol";
import {Controller} from "src/Controller.sol";
import {AggregatorV3Interface} from "@chainlink/interfaces/feeds/AggregatorV3Interface.sol";

contract DeployScript is Script {
    address deployer;
    address admin;

    uint256 liquidationThreshold;
    uint256 interestRate;
    uint24 ammPoolFee;

    MockMintableERC20 eth;
    MockMintableERC20 btc;
    MockMintableERC20 usdc;
    MockMintableERC20 usdt;

    AggregatorV3Interface ethPriceFeed;
    AggregatorV3Interface btcPriceFeed;
    AggregatorV3Interface usdcPriceFeed;
    AggregatorV3Interface usdtPriceFeed;

    MockNonFungiblePositionManager nonFungiblePositionManager;
    MockSwapRouter swapRouter;
    MockFuturesMarket futuresMarket;

    StratergyPool ethPool;
    StratergyPool btcPool;
    StratergyPool usdcPool;

    Controller controller;

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("DEPLOYER_PRIVATE_KEY");
        uint256 adminPrivateKey = vm.envUint("ADMIN_PRIVATE_KEY");

        deployer = vm.addr(deployerPrivateKey);
        admin = vm.addr(adminPrivateKey);

        liquidationThreshold = 0.95 * 1e27; // 95% -> 0.95 -> to Ray -> 0.95 * 1e27 -> 1e26
        interestRate = 0.1 * 1e27; // 10% -> 0.10 -> to Ray -> 0.1 * 1e27 -> 1e26
        ammPoolFee = 0;

        console.log("Deploying all contracts");

        vm.startBroadcast(deployer);

        eth = new MockMintableERC20("Ether", "ETH", 1 * 1e18, admin);
        btc = new MockMintableERC20("Bitcoin", "BTC", 0.1 * 1e18, admin);
        usdc = new MockMintableERC20("USD Coin", "USDC", 2000 * 1e6, admin);
        usdt = new MockMintableERC20("Tether", "USDT", 2000 * 1e6, admin);

        // TODO: find the real once and change it
        ethPriceFeed = AggregatorV3Interface(address(0));
        btcPriceFeed = AggregatorV3Interface(address(0));
        usdcPriceFeed = AggregatorV3Interface(address(0));
        usdtPriceFeed = AggregatorV3Interface(address(0));

        nonFungiblePositionManager = new MockNonFungiblePositionManager(0, admin);

        address[] memory _tokens = new address[](4);
        _tokens[0] = address(eth);
        _tokens[1] = address(btc);
        _tokens[2] = address(usdc);
        _tokens[3] = address(usdt);

        address[] memory _priceFeeds = new address[](4);
        _priceFeeds[0] = address(ethPriceFeed);
        _priceFeeds[1] = address(btcPriceFeed);
        _priceFeeds[2] = address(usdcPriceFeed);
        _priceFeeds[3] = address(usdtPriceFeed);

        swapRouter = new MockSwapRouter(_tokens, _priceFeeds, admin);
        futuresMarket = new MockFuturesMarket(_tokens, _priceFeeds, admin);

        controller = new Controller(liquidationThreshold, admin);

        ethPool = new StratergyPool(
            address(eth),
            address(controller),
            admin,
            address(usdc),
            ammPoolFee,
            address(nonFungiblePositionManager),
            address(swapRouter),
            address(futuresMarket),
            address(ethPriceFeed)
        );

        btcPool = new StratergyPool(
            address(btc),
            address(controller),
            admin,
            address(usdc),
            ammPoolFee,
            address(nonFungiblePositionManager),
            address(swapRouter),
            address(futuresMarket),
            address(btcPriceFeed)
        );

        usdcPool = new StratergyPool(
            address(usdc),
            address(controller),
            admin,
            address(usdt),
            ammPoolFee,
            address(nonFungiblePositionManager),
            address(swapRouter),
            address(futuresMarket),
            address(usdcPriceFeed)
        );

        vm.stopBroadcast();

        console.log("Deployed all contracts");

        console.log("ETH: ", address(eth));
        console.log("BTC: ", address(btc));
        console.log("USDC: ", address(usdc));
        console.log("USDT: ", address(usdt));

        console.log("ETH Pool: ", address(ethPool));
        console.log("BTC Pool: ", address(btcPool));
        console.log("USDC Pool: ", address(usdcPool));

        console.log("Controller: ", address(controller));

        console.log("Adding Pools and giving permissions to the contracts");

        vm.startBroadcast(admin);

        controller.addPool(address(ethPool));
        controller.addPool(address(btcPool));
        controller.addPool(address(usdcPool));

        eth._addMinterBurner(address(swapRouter));
        btc._addMinterBurner(address(swapRouter));
        usdc._addMinterBurner(address(swapRouter));
        usdt._addMinterBurner(address(swapRouter));

        eth._addMinterBurner(address(nonFungiblePositionManager));
        btc._addMinterBurner(address(nonFungiblePositionManager));
        usdc._addMinterBurner(address(nonFungiblePositionManager));
        usdt._addMinterBurner(address(nonFungiblePositionManager));

        eth._addMinterBurner(address(futuresMarket));
        btc._addMinterBurner(address(futuresMarket));
        usdc._addMinterBurner(address(futuresMarket));
        usdt._addMinterBurner(address(futuresMarket));

        futuresMarket._addAuthorized(address(ethPool));
        futuresMarket._addAuthorized(address(btcPool));
        futuresMarket._addAuthorized(address(usdcPool));

        eth._addMinterBurner(admin);
        btc._addMinterBurner(admin);
        usdc._addMinterBurner(admin);

        eth._mint_(address(ethPool), 100000 * 1e18);
        btc._mint_(address(btcPool), 10000 * 1e18);
        usdc._mint_(address(usdcPool), 50000000 * 1e6);

        vm.stopBroadcast();

        console.log("Permissions given to the contracts");
        console.log("Added liquidity to the pools");
    }
}
