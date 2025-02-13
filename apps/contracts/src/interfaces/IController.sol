// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IController {
    error PoolAlreadyExists();

    error PoolDoesNotExist();

    function createPool(address token_, uint256 apy_) external;

    function addPool(address token_, address pool_) external;

    function removePool(address token_) external;

    function poolFor(address token_) external view returns (address);

    function totalCollateralOfInUSD(address account_) external view returns (uint256);

    function totalDebtOfInUSD(address account_) external view returns (uint256);
}
