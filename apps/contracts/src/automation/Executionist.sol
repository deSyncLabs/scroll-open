// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IPool} from "src/interfaces/IPool.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";

contract Executionist is AccessControl {
    bytes32 public constant AUTHORIZED_ROLE = keccak256("AUTHORIZED_ROLE");

    event Executed(bool indexed executedUnexecute, bool indexed executedExecute, uint256 indexed timestamp);

    IPool public pool;
    uint256 public run;

    constructor(address pool_, address owner_) {
        pool = IPool(pool_);
        run = 0;

        _grantRole(DEFAULT_ADMIN_ROLE, owner_);
        _setRoleAdmin(AUTHORIZED_ROLE, DEFAULT_ADMIN_ROLE);
    }

    function execute() external onlyRole(AUTHORIZED_ROLE) {
        bool executedUnexecute = false;
        bool executedExecute = false;

        if (pool.locked()) {
            pool.unexecuteStratergy();
            executedUnexecute = true;
        }

        if (!pool.locked()) {
            pool.executeStratergy();
            executedExecute = true;
        }

        run += 1;

        emit Executed(executedUnexecute, executedExecute, block.timestamp);
    }
}
