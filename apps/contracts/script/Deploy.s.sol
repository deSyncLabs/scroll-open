// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {MockMintableERC20} from "src/mocks/MockMintableERC20.sol";
import {MockAggregatorV3} from "src/mocks/MockAggregatorV3.sol";
import {MockNonFungiblePositionManager} from "src/mocks/MockNonFungiblePositionManager.sol";
import {MockSwapRouter} from "src/mocks/MockSwapRouter.sol";
import {MockFuturesMarket} from "src/mocks/MockFuturesMarket.sol";
import {StratergyPool} from "src/StratergyPool.sol";
import {Controller} from "src/Controller.sol";

contract DeployScript is Script {
    MockMintableERC20 eth;
    MockMintableERC20 btc;
    MockMintableERC20 usdc;
    MockMintableERC20 usdt;

    MockAggregatorV3 ethPriceFeed;
    MockAggregatorV3 btcPriceFeed;
    MockAggregatorV3 usdcPriceFeed;
    MockAggregatorV3 usdtPriceFeed;

    MockNonFungiblePositionManager nonFungiblePositionManager;
    MockSwapRouter swapRouter;
    MockFuturesMarket futuresMarket;

    StratergyPool ethPool;
    StratergyPool btcPool;
    StratergyPool usdcPool;

    Controller controller;

    function run() public {
        vm.startBrodcast();
    }
}
