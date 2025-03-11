// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {Clones} from "@openzeppelin/contracts/proxy/Clones.sol";
import {MockMintableERC20} from "src/mocks/MockMintableERC20.sol";
import {MockNonFungiblePositionManager} from "src/mocks/MockNonFungiblePositionManager.sol";
import {MockSwapRouter} from "src/mocks/MockSwapRouter.sol";
import {MockFuturesMarket} from "src/mocks/MockFuturesMarket.sol";
import {DEToken} from "src/DEToken.sol";
import {DebtToken} from "src/DebtToken.sol";
import {StratergyPool} from "src/StratergyPool.sol";
import {IStratergyPool} from "src/interfaces/IStratergyPool.sol";
import {Controller} from "src/Controller.sol";
import {Executionist} from "src/automation/Executionist.sol";
import {WithdrawDistributor} from "src/automation/WithdrawDistributor.sol";
import {BorrowDistributor} from "src/automation/BorrowDistributor.sol";
import {AggregatorV3Interface} from "@chainlink/interfaces/feeds/AggregatorV3Interface.sol";

contract DeployScript is Script {
    using Clones for address;

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

    IStratergyPool ethPool;
    IStratergyPool btcPool;
    IStratergyPool usdcPool;

    Controller controller;

    Executionist btcPoolExecutionist;
    Executionist ethPoolExecutionist;
    Executionist usdcPoolExecutionist;

    WithdrawDistributor btcPoolWithdrawDistributor;
    WithdrawDistributor ethPoolWithdrawDistributor;
    WithdrawDistributor usdcPoolWithdrawDistributor;

    BorrowDistributor btcPoolBorrowDistributor;
    BorrowDistributor ethPoolBorrowDistributor;
    BorrowDistributor usdcPoolBorrowDistributor;

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("DEPLOYER_PRIVATE_KEY");
        uint256 adminPrivateKey = vm.envUint("ADMIN_PRIVATE_KEY");

        deployer = vm.addr(deployerPrivateKey);
        admin = vm.addr(adminPrivateKey);

        liquidationThreshold = 0.95 * 1e27; // 95% -> 0.95 -> to Ray -> 0.95 * 1e27 -> 1e26
        interestRate = 0.018 * 1e27; // 18% -> 0.18 -> to Ray -> 0.018 * 1e27 -> 1e25
        ammPoolFee = 0;

        console.log("Deploying all contracts");

        vm.startBroadcast(deployer);
        eth = new MockMintableERC20("Ether", "ETH", 1 * 1e18, admin);
        btc = new MockMintableERC20("Bitcoin", "BTC", 0.1 * 1e18, admin);
        usdc = new MockMintableERC20("USD Coin", "USDC", 2000 * 1e18, admin);
        usdt = new MockMintableERC20("Tether", "USDT", 2000 * 1e18, admin);
        vm.stopBroadcast();

        address ethPriceFeedAddress = vm.envAddress("ETH_USD_PRICE_FEED");
        address btcPriceFeedAddress = vm.envAddress("BTC_USD_PRICE_FEED");
        address usdcPriceFeedAddress = vm.envAddress("USDC_USD_PRICE_FEED");
        address usdtPriceFeedAddress = vm.envAddress("USDT_USD_PRICE_FEED");

        ethPriceFeed = AggregatorV3Interface(ethPriceFeedAddress);
        btcPriceFeed = AggregatorV3Interface(btcPriceFeedAddress);
        usdcPriceFeed = AggregatorV3Interface(usdcPriceFeedAddress);
        usdtPriceFeed = AggregatorV3Interface(usdtPriceFeedAddress);

        vm.broadcast(deployer);
        nonFungiblePositionManager = new MockNonFungiblePositionManager(interestRate, admin);

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

        vm.broadcast(deployer);
        swapRouter = new MockSwapRouter(_tokens, _priceFeeds, admin);

        vm.broadcast(deployer);
        futuresMarket = new MockFuturesMarket(_tokens, _priceFeeds, admin);

        vm.broadcast(deployer);
        address deTokenImplementation = address(new DEToken());

        vm.broadcast(deployer);
        address debtTokenImplementation = address(new DebtToken());

        vm.broadcast(deployer);
        address stratergyPoolImplementation = address(new StratergyPool(deTokenImplementation, debtTokenImplementation));

        vm.broadcast(deployer);
        controller = new Controller(liquidationThreshold, admin);

        vm.startBroadcast(deployer);
        ethPool = IStratergyPool(address(stratergyPoolImplementation.clone()));
        ethPool.initialize(
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
        vm.stopBroadcast();

        vm.startBroadcast(deployer);
        btcPool = IStratergyPool(address(stratergyPoolImplementation.clone()));
        btcPool.initialize(
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
        vm.stopBroadcast();

        vm.startBroadcast(deployer);
        usdcPool = IStratergyPool(address(stratergyPoolImplementation.clone()));
        usdcPool.initialize(
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

        vm.startBroadcast(deployer);
        btcPoolExecutionist = new Executionist(address(btcPool), admin);
        ethPoolExecutionist = new Executionist(address(ethPool), admin);
        usdcPoolExecutionist = new Executionist(address(usdcPool), admin);
        vm.stopBroadcast();

        vm.startBroadcast(deployer);
        btcPoolWithdrawDistributor = new WithdrawDistributor(address(btcPool), admin);
        ethPoolWithdrawDistributor = new WithdrawDistributor(address(ethPool), admin);
        usdcPoolWithdrawDistributor = new WithdrawDistributor(address(usdcPool), admin);
        vm.stopBroadcast();

        vm.startBroadcast(deployer);
        btcPoolBorrowDistributor = new BorrowDistributor(address(btcPool), admin);
        ethPoolBorrowDistributor = new BorrowDistributor(address(ethPool), admin);
        usdcPoolBorrowDistributor = new BorrowDistributor(address(usdcPool), admin);
        vm.stopBroadcast();

        console.log("Deployed all contracts");

        console.log("ETH: ", address(eth));
        console.log("BTC: ", address(btc));
        console.log("USDC: ", address(usdc));
        console.log("USDT: ", address(usdt));

        console.log("ETH Pool: ", address(ethPool));
        console.log("BTC Pool: ", address(btcPool));
        console.log("USDC Pool: ", address(usdcPool));

        console.log("ETH deToken: ", address(ethPool.deToken()));
        console.log("BTC deToken: ", address(btcPool.deToken()));
        console.log("USDC deToken: ", address(usdcPool.deToken()));

        console.log("ETH debtToken: ", address(ethPool.debtToken()));
        console.log("BTC debtToken: ", address(btcPool.debtToken()));
        console.log("USDC debtToken: ", address(usdcPool.debtToken()));

        console.log("Controller: ", address(controller));

        console.log("ETH Executionist: ", address(ethPoolExecutionist));
        console.log("BTC Executionist: ", address(btcPoolExecutionist));
        console.log("USDC Executionist: ", address(usdcPoolExecutionist));

        console.log("ETH WithdrawDistributor: ", address(ethPoolWithdrawDistributor));
        console.log("BTC WithdrawDistributor: ", address(btcPoolWithdrawDistributor));
        console.log("USDC WithdrawDistributor: ", address(usdcPoolWithdrawDistributor));

        console.log("ETH BorrowDistributor: ", address(ethPoolBorrowDistributor));
        console.log("BTC BorrowDistributor: ", address(btcPoolBorrowDistributor));
        console.log("USDC BorrowDistributor: ", address(usdcPoolBorrowDistributor));

        console.log("Adding Pools and giving permissions to the contracts");

        vm.startBroadcast(admin);
        controller.addPool(address(ethPool));
        controller.addPool(address(btcPool));
        controller.addPool(address(usdcPool));
        vm.stopBroadcast();

        vm.startBroadcast(admin);
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

        eth._addMinterBurner(admin);
        btc._addMinterBurner(admin);
        usdc._addMinterBurner(admin);
        vm.stopBroadcast();

        vm.startBroadcast(admin);
        futuresMarket._addAuthorized(address(ethPool));
        futuresMarket._addAuthorized(address(btcPool));
        futuresMarket._addAuthorized(address(usdcPool));
        vm.stopBroadcast();

        vm.startBroadcast(admin);
        eth._mint_(address(ethPool), 100000 * 1e18);
        btc._mint_(address(btcPool), 10000 * 1e18);
        usdc._mint_(address(usdcPool), 50000000 * 1e18);
        vm.stopBroadcast();

        vm.startBroadcast(admin);
        ethPool.grantRole(ethPool.AUTHORIZED_ROLE(), address(ethPoolExecutionist));
        btcPool.grantRole(btcPool.AUTHORIZED_ROLE(), address(btcPoolExecutionist));
        usdcPool.grantRole(usdcPool.AUTHORIZED_ROLE(), address(usdcPoolExecutionist));
        vm.stopBroadcast();

        console.log("Permissions given to the contracts");
        console.log("Added liquidity to the pools");

        console.log("Executing the strategies");

        vm.startBroadcast(admin);
        ethPool.executeStratergy();
        btcPool.executeStratergy();
        usdcPool.executeStratergy();
        vm.stopBroadcast();

        console.log("Executed the strategies");
    }
}
