// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {DEToken} from "../src/DEToken.sol";

contract DETokenTest is Test {
    DEToken public deToken;

    function setup() public {
        deToken = new DEToken("DEToken", "DET", address(this));
        deToken.mint(address(this), 1000);
    }

   
}
