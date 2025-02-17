// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {Controller} from "src/Controller.sol";
import {Pool} from "src/Pool.sol";
import {IDEToken} from "src/interfaces/IDEToken.sol";
import {IDebtToken} from "src/interfaces/IDebtToken.sol";
import {MockERC20} from "src/mocks/MockERC20.sol";
import {MockAggregatorV3} from "src/mocks/MockAggregatorV3.sol";

contract ControllerTest is Test {
    address superDeployer;
    address deployer;
    address owner;
    address alice;
    address bob;

    MockERC20 eth;
    MockERC20 btc;
    Pool ethPool;
    Pool btcPool;
    IDEToken ethDEToken;
    IDEToken btcDEToken;
    IDebtToken ethDebtToken;
    IDebtToken btcDebtToken;
    Controller controller;

    function setUp() public {
        superDeployer = vm.addr(42);
        deployer = vm.addr(69420);
        owner = vm.addr(42069);
        alice = vm.addr(69);
        bob = vm.addr(420);

        vm.startPrank(superDeployer);
        address mockEthAggregator = address(new MockAggregatorV3(3000 * 1e8, 8));
        address mockBtcAggregator = address(new MockAggregatorV3(100000 * 1e18, 18));
        
        eth = new MockERC20("ETH", "ETH");
        btc = new MockERC20("BTC", "BTC");

        eth.transfer(alice, 1000 * 1e18);
        eth.transfer(bob, 1000 * 1e18);
        btc.transfer(alice, 1000 * 1e18);
        btc.transfer(bob, 1000 * 1e18);
        
        vm.stopPrank();


    }
}
