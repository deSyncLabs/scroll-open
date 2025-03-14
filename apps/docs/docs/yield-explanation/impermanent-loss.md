---
sidebar_position: 1
---

# What is Impermanent Loss?

Impermanent Loss (IL) is a well-known phenomenon encountered by Liquidity Providers (LPs) on Automated Market Makers (AMMs) such as Uniswap V3 and other similar decentralized exchanges. The loss occurs when the relative price of the pooled assets changes from the time of deposit, causing the LP to hold more of the underperforming asset and less of the outperforming one.

## Definition

Impermanent Loss is the difference in value between holding two assets in a liquidity pool versus holding them outright (1:1 in a wallet). If one asset appreciates or depreciates significantly, the LP ends up with a suboptimal token mix compared to a simple HODL approach.

## Impact on Liquidity Providers

- **Price Rises:** LP has fewer tokens of the asset that has gone up.
- **Price Drops:** LP has more tokens of the asset that has fallen.

In either case, the LP can suffer a net loss of value (relative to just holding the tokens) if the LP is not hedged.

## Uniswap V3 Specifics

Uniswap V3 uses concentrated liquidity, allowing providers to select a price range [`Pmin`⁡, `Pmax`]. The pool’s token ratio changes non-linearly as price moves within that range. If the price exits the range, the LP ends up entirely in one asset, no longer earning fees. This structure increases capital efficiency but also complicates hedging because the LP’s net exposure changes dynamically with price.

Let’s walk through a realistic example step by step.

### Example

- You start with:
    - 1 ETH and 2000 USDC at a price of 2000 USDC/ETH.
- You deposit these into a Uniswap V3 LP position concentrated around the current price. Let’s say for simplicity you pick a range that comfortably includes the current price (e.g., 1600 to 2500 USDC/ETH).
- At the moment of deposit, the LP consists of exactly:
    - 1 ETH
    - 2000 USDC
    - Total value = 1 \* 2000 + 2000 = 4000 USDC worth of value.

Without any hedge, if ETH price moves significantly, you won’t just have “1 ETH and 2000 USDC” left when you exit the position. Instead, depending on where the price ends up, you’ll have a different mix of ETH and USDC. For example, if the price goes up significantly, you’ll end up with mostly USDC; if it goes down, you’ll end up with mostly ETH. So, if you deposit 1 ETH into the pool today, valued at $1,500, and the price of ETH rises to $5,000 over the next two months, your ETH, which was converted to USDC, would effectively be sold at around $2,000. This means you would miss out on the additional $3,000 in profit that you could have earned by simply holding your ETH in your wallet.
