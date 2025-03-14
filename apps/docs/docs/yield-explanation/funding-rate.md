---
sidebar_position: 2
---

# What is Funding Rate?

Funding rate fees are periodic payments exchanged between traders holding long and short positions in perpetual futures contracts. Unlike traditional futures contracts, perpetual futures have no expiration date. To ensure that the price of perpetual futures remains close to the spot price of the underlying asset, funding rates are used as a mechanism to incentivise or discourage buying and selling, thereby balancing supply and demand.

## How Funding Rates Work

1. **Calculation:**

- Funding rates are usually calculated every 8 hours and are based on two primary components: the interest rate and the premium/discount of the perpetual contract price relative to the spot price.
- **Interest Rate:** Reflects the cost of holding positions, often derived from the difference in borrowing rates between the base and quote currencies.
- **Premium/Discount:** The difference between the perpetual contract price and the spot price. If the perpetual price is above the spot price (positive premium), the funding rate is positive, and long positions pay short positions. Conversely, if the perpetual price is below the spot price (negative premium), the funding rate is negative, and short positions pay long positions.

2. **Payment Mechanism:**

- Funding rate payments are exchanged directly between traders. The exchange facilitates this transfer but does not typically collect these fees.
- If the funding rate is positive, long position holders pay the fee to short position holders. If negative, short position holders pay the fee to long position holders.

## Why Does Funding Rate Fees Exist?

1. **Price Convergence:**

- **Primary Purpose:** The main reason funding rate fees exist is to ensure that the price of perpetual futures contracts converges with the spot price of the underlying asset. Without an expiration date to force this convergence, funding rates provide a financial incentive for traders to arbitrage any discrepancies.
- **Maintaining Equilibrium:** When the perpetual futures price deviates significantly from the spot price, funding rates encourage traders to take positions that will bring the two prices back in line. For instance, if the perpetual price is too high, a positive funding rate incentivises selling, thereby pushing the price down towards the spot price.

2. **Market Balance:**

- **Supply and Demand:** Funding rates help balance supply and demand in the perpetual futures market. If there are more long positions than short positions, the funding rate will be positive, encouraging traders to open short positions and balance the market.
- **Risk Management:** By aligning the futures price with the spot price, funding rates help manage the risk of holding positions in perpetual futures. This reduces the likelihood of extreme price discrepancies, contributing to market stability.

3. **Trader Behaviour:**

- **Incentivising Participation:** Funding rates can attract liquidity providers and arbitrageurs to the market. These participants help keep the market efficient by ensuring that prices remain aligned with underlying values.
- **Discouraging Extreme Positions:** High funding rates can discourage excessive leverage and speculative positions by making it costly to maintain large positions over time. This helps prevent market manipulation and extreme volatility.
