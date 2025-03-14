// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IController {
    error LiquidationThresholdMustBeLessThan100();

    error LiquidationThresholdNotReached();

    error PoolAlreadyExists();

    error PoolDoesNotExist();

    error CollateralNotEnough();

    event PoolAdded(address indexed token, address indexed pool, uint256 timestamp);

    event PoolRemoved(address indexed token, address indexed pool, uint256 timestamp);

    function addPool(address pool_) external;

    function removePool(address token_) external;

    function borrow(address token_, uint256 amount_) external;

    function liquidate(address account_) external;

    function setLiquidationThreshold(uint256 liquidationThreshold_) external;

    function poolFor(address token_) external view returns (address);

    function totalCollateralOfInUSD(address account_) external view returns (uint256);

    function totalDebtOfInUSD(address account_) external view returns (uint256);

    function healthFactorFor(address account_) external view returns (uint256);

    function liquidationThreshold() external view returns (uint256);
}
