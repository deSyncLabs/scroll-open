---
sidebar_position: 3
---

# Protocol Overview

![workings](/img/workings-dark.png)

## Supplying

When a user supplies assets to the pool they are giving deTokens (liquid staking token) in return. These deTokens auto increment with accumulated interest everytime the pool rebalances.

The supplied tokens are used to provide liquidity to an AMM.

The LP position from the AMM is used as collateral to open a short position on the perpetual futures contract of the corresponding asset.

At the end of each cycle - which is typically 12-24 hours - the pool rebalances. During rebalancing, the short position is closed and liquidity is taken out of the exchange and we calculate the earned profit.

The profit is `yield generated for providing liquidity` + `profit generated on the short position`. To keep calculations simple, deSync Labs takes the funding rate as protocol fees.

In case of a loss on the short position, we use acquired yield to payback the loss. This allows us to stay delta neutral.

:::info
If the protcol is not able to make a profit after paying back the loss, the yield provided to the users for the next cycle will be 0.
:::

## Borrowing

When borrowing your supplied assets double as the collateral for your loan.

When a user wants to borrow some asset they need to submit an intent to borrow to the pool.

Once the pools rebalance the user will be able to withdraw what they have borrowed.

When a user borrows we also mint equal amount of debtTokens and transfer them to the user. debtTokens are not transferable and represent a users current loan.

When borrowing the user also needs to make sure that their Health Factor is kept >1 or they risk getting liquidated.

:::info
Due to the architecture of the pools users are not able to borrow immediately.

The rebalancing can take upto 24 hours.
:::

## Repaying

You can payback your debt anytime.

Once a user pays back their debtTokens are burnt and their Health Factor is improved.

## Withdrawing

When a user wants to withdraw their supplied assets they need to submit an intent to withdraw to the pool.

Once the pool rebalances the user will be able withdraw their assets.

:::info
Due to the architecture of the pools users are not able to withdraw immediately.

The rebalancing can take upto 24 hours.
:::
