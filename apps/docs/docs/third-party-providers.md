---
sidebar_position: 4
---

# Third Party Providers

## Chainlink Data Feeds

deSync relies on Chainlink Price Feeds to calculate your position, i.e. how much you can borrow as well as when to allow for a given user to be liquidated.

We realise that this could create over reliance on a single provider and are actively working towards integrating other providers like Pyth and API3.

## Chainlink Automation

deSync relies on Chainlink Automation to trigger pool rebalancing on a set schedule. This allows us to ensure that the cron that triggers the rebalancing is kept fairly decentralized.