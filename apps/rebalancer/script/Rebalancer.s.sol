// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {IPool} from "src/interfaces/IPool.sol";

contract RebalancerScript is Script {
    IPool public pool;

    function run() public {
        uint256 rebalancerEOAPrivateKey = vm.envUint("REBALANCER_EOA_PRIVATE_KEY");
        rebalancerEOA = vm.addr(rebalancerEOAPrivateKey);

        address poolAddress = vm.envAddress("POOL_ADDRESS");
        pool = IPool(poolAddress);

        if (pool.isLocked()) {
            vm.startBroadcast(rebalancerEOA);
            pool.unexecuteStratergy();
            vm.stopBroadcast();

            console.log("Unexecuted strategy");
        }

        if (!pool.isLocked()) {
            vm.startBroadcast(rebalancerEOA);
            pool.executeStratergy();
            vm.stopBroadcast();

            console.log("Executed strategy");
        }
    }
}
