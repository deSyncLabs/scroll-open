// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {IPool} from "src/interfaces/IPool.sol";

contract DistributeBorrowScript is Script {
    IPool public BTCPool;
    IPool public ETHPool;
    IPool public USDCPool;

    function run() public {
        uint256 distributorEOAPrivateKey = vm.envUint("DISTRIBUTOR_EOA_PRIVATE_KEY");
        address distributorEOA = vm.addr(distributorEOAPrivateKey);

        address BTCPoolAddress = vm.envAddress("BTC_POOL_ADDRESS");
        address ETHPoolAddress = vm.envAddress("ETH_POOL_ADDRESS");
        address USDCPoolAddress = vm.envAddress("USDC_POOL_ADDRESS");

        BTCPool = IPool(BTCPoolAddress);
        ETHPool = IPool(ETHPoolAddress);
        USDCPool = IPool(USDCPoolAddress);

        console.log("Distribution of borrow for all pools");

        vm.startBroadcast(distributorEOA);
        BTCPool.borrowForEveryone();
        vm.stopBroadcast();

        console.log("Distributed borrow for BTC Pool");

        vm.startBroadcast(distributorEOA);
        ETHPool.borrowForEveryone();
        vm.stopBroadcast();

        console.log("Distributed borrow for ETH Pool");

        vm.startBroadcast(distributorEOA);
        USDCPool.borrowForEveryone();
        vm.stopBroadcast();

        console.log("Distributed borrow for USDC Pool");

        console.log("Distribution of borrow for all pools completed");
    }
}
