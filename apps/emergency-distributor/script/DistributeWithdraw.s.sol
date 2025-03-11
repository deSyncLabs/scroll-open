// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {IPool} from "src/interfaces/IPool.sol";

contract DistributeWithdrawScript is Script {
    IPool public BTCPool;
    IPool public ETHPool;
    IPool public USDCPool;

    function run() {
        uint256 distributorEOAPrivateKey = vm.envUint("DISTRIBUTOR_EOA_PRIVATE_KEY");
        address distributorEOA = vm.addr(distributorEOAPrivateKey);

        address BTCPoolAddress = vm.envAddress("BTC_POOL_ADDRESS");
        address ETHPoolAddress = vm.envAddress("ETH_POOL_ADDRESS");
        address USDCPoolAddress = vm.envAddress("USDC_POOL_ADDRESS");

        BTCPool = IPool(BTCPoolAddress);
        ETHPool = IPool(ETHPoolAddress);
        USDCPool = IPool(USDCPoolAddress);

        console.log("Distribution of withdraw for all pools");

        vm.startBroadcast(distributorEOA);
        BTCPool.withdrawForEveryone();
        vm.stopBroadcast();

        console.log("Distributed withdraw for BTC Pool");

        vm.startBroadcast(distributorEOA);
        ETHPool.withdrawForEveryone();
        vm.stopBroadcast();

        console.log("Distributed withdraw for ETH Pool");

        vm.startBroadcast(distributorEOA);
        USDCPool.withdrawForEveryone();
        vm.stopBroadcast();

        console.log("Distributed withdraw for USDC Pool");

        console.log("Distribution of withdraw for all pools completed");
    }
}
