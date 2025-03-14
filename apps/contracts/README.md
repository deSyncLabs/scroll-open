# Contracts

This project contains the core and automation smartcontracs for deSync.

```ml
mocks
├─ MockAggregatorV3.sol - "Mock Chainlink Price Feed for testing."
├─ MockERC20.sol - "Mock ERC20 for early testing."
├─ MockFuturesMarket.sol - "Simulation of the futures market."
├─ MockMintableERC20.sol - "Mock mintable ERC20 for testing and also used for the faucet."
├─ MockMintableERC721.sol - "Mock mintable ERC721 to track liquidity positions in MockNonFungiblePositionManager."
├─ MockNonFungiblePositionManager.sol - "Simulating Uniswap V3 based liquidity position manager."
├─ MockSwapRouter.sol - "Simulating Uniswap V3 based swaps."
automation
├─ Executionist.sol - "Rebalances pools. Triggered using Chainlink Automation."
├─ BorrowDistributor.sol - "Automatically distributes tokens for borrow intents. Triggered using Chainlink Automation"
├─ WithdrawDistributor.sol - "Automatically distributes tokens for withdraw intents. Triggered using Chainlink Automation"
interfaces
├─ IFuturesMarket.sol - "Futures Market Interface."
├─ IMintableERC20.sol - "Mintable ERC20 Interface. Extends IERC20."
├─ IDEToken.sol - "DEToken Interface. Extends IERC20."
├─ IDebtToken.sol - "DebtToken Interface. Extends IERC20."
├─ IPool.sol - "Pool Interface."
├─ IStratergyPool.sol - "Strtergy Pool Interface. Extends IPool."
├─ IController.sol - "Controller Interface."
DEToken.sol - "DEToken implements a transactionless auto incrementing token that increments every time the pool rebalances, reflecting the accrued yield."
DebtToken.sol - "DetToken represents a users current debt. These tokens are non transferable."
Pool.sol - "Implents the abstract Pool contract with all the pool functionalities other than the yield geenration startergy."
StratergyPool.sol - "Extends the Pool contract and implements the yield generation stratergy."
Controller.sol - "Implements the hub contract for all the pools which also keeps track of a user health factor and manages debt."
```

## Safety

This software is experimental and unaudited, and is provided on an 'as is' and 'as available' basis. We do not give any warranties and will not be liable for any loss incurred through any use of this codebase.
