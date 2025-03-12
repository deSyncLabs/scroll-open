// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {IPool} from "src/interfaces/IPool.sol";

contract RebalanceScript is Script {
    IPool public BTCPool;
    IPool public ETHPool;
    IPool public USDCPool;

    function run() public {
        uint256 rebalancerEOAPrivateKey = vm.envUint("REBALANCER_EOA_PRIVATE_KEY");
        address rebalancerEOA = vm.addr(rebalancerEOAPrivateKey);

        address BTCPoolAddress = vm.envAddress("BTC_POOL_ADDRESS");
        address ETHPoolAddress = vm.envAddress("ETH_POOL_ADDRESS");
        address USDCPoolAddress = vm.envAddress("USDC_POOL_ADDRESS");

        BTCPool = IPool(BTCPoolAddress);
        ETHPool = IPool(ETHPoolAddress);
        USDCPool = IPool(USDCPoolAddress);

        console.log("Trying to unexecute stratergy for all pools");

        if (BTCPool.locked()) {
            vm.startBroadcast(rebalancerEOA);
            BTCPool.unexecuteStratergy();
            vm.stopBroadcast();

            console.log("Unexecuted strategy for BTC Pool");
        }

        if (ETHPool.locked()) {
            vm.startBroadcast(rebalancerEOA);
            ETHPool.unexecuteStratergy();
            vm.stopBroadcast();

            console.log("Unexecuted strategy for ETH Pool");
        }

        if (USDCPool.locked()) {
            vm.startBroadcast(rebalancerEOA);
            USDCPool.unexecuteStratergy();
            vm.stopBroadcast();

            console.log("Unexecuted strategy for USDC Pool");
        }

        console.log("Trying to execute stratergy for all pools");

        if (!BTCPool.locked()) {
            vm.startBroadcast(rebalancerEOA);
            BTCPool.executeStratergy();
            vm.stopBroadcast();

            console.log("Executed strategy for BTC Pool");
        }

        if (!ETHPool.locked()) {
            vm.startBroadcast(rebalancerEOA);
            ETHPool.executeStratergy();
            vm.stopBroadcast();

            console.log("Executed strategy for ETH Pool");
        }

        if (!USDCPool.locked()) {
            vm.startBroadcast(rebalancerEOA);
            USDCPool.executeStratergy();
            vm.stopBroadcast();

            console.log("Executed strategy for USDC Pool");
        }
    }
}
