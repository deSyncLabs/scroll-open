---
sidebar_position: 3
---

# Yield Generation

deSync offers a yield range of 5-100%+. We generate this yiel by providing liquidity to AMMs. To prevent [Impermanent Loss (IP)](/yield-explanation/impermanent-loss), we create a hedge by opening a perpetual futures short position. Historically the funding rate for crypto futures has mostly been positve which means holding a short postion also allows us to consistently earn from funding rates.

## Establish a Futures Position at the Start:

Right after you create the LP position at P=2000 USDC/ETH, open a short futures position on ETH worth exactly 1 ETH.

- On a futures exchange (centralized or decentralized), you short 1 ETH at 2000 USDC/ETH. This means:
    - If the price of ETH goes down, your short futures position will make a profit in USDC.
    - If the price of ETH goes up, your short futures position will incur a loss in USDC.

After this step, your overall portfolio looks like this:

- Uniswap LP position: 1 ETH + 2000 USDC (in a liquidity position).
- Futures position: Short 1 ETH at 2000 USDC/ETH.

Net effect at the start:

- On-chain, you have the LP tokens representing 1 ETH + 2000 USDC worth of liquidity.
- Off-chain (or on a derivatives platform), you have a -1 ETH position (short) that balances out your ETH exposure.

Essentially, at this initial point, your overall ETH exposure is close to zero:

- LP has 1 ETH in it, but you’re short 1 ETH in futures.

The USDC exposure initially is just the 2000 USDC in the LP (futures do not affect your initial USDC since the short is just a contract, not spot).

## Price Movement Scenarios:

Let’s consider two scenarios at the time you want to exit: when price moves up and when price moves down. In both cases, you’ll close your LP position and your futures position and see what you end up with.

### Scenario A: Price Goes Up to 2200 USDC/ETH

- Uniswap LP Position After Price Increase: When ETH price increases, the Uniswap V3 position shifts towards holding fewer ETH and more USDC. Let’s say that when you close the position at 2200 USDC/ETH, the LP now consists of approximately:
    - 0.9 ETH and 2420 USDC (this is just an illustrative example of what might happen; the exact amounts depend on the chosen price range and how the liquidity curve works).
- Notice you now have fewer than 1 ETH because as the price rose, the pool effectively sold some of your ETH for USDC.
- **Futures Position:** You were short 1 ETH from 2000 USDC/ETH. Now ETH is 2200 USDC/ETH. Your short position loses money because you bet on ETH going down and it went up.
    - Entry price: 2000 USDC/ETH
    - Exit price: 2200 USDC/ETH
    - Loss per ETH: 2200 - 2000 = 200 USDC loss
- Since you shorted 1 ETH, you have a 200 USDC loss on the futures trade.

#### Combine Both Outcomes at Exit:

- LP gives you: ~0.9 ETH + 2420 USDC
- Futures gives you: -200 USDC (because you have to buy back the ETH at a higher price)

After closing the futures position, your net holdings:

- ETH: 0.9 ETH
- USDC: 2420 - 200 = 2220 USDC

You now have more USDC than you started with (2220 vs. the initial 2000) and less ETH (0.9 vs. initial 1). But remember, the idea is to reconstruct your original principal of 1 ETH and 2000 USDC. Since ETH is now worth 2200 USDC, you can use some of your extra USDC to buy back 0.1 ETH (which at 2200 USDC/ETH costs about 220 USDC). After buying 0.1 ETH back:

- You spend 220 USDC to buy 0.1 ETH.
- Now you have:
    - ETH: 0.9 ETH + 0.1 ETH = 1 ETH
    - USDC: 2220 USDC - 220 USDC = 2000 USDC

**Result:** You end up with the same 1 ETH and 2000 USDC you started with, despite the price going up.

### Scenario B: Price Goes Down to 1800 USDC/ETH

- Uniswap LP Position After Price Drop: If the price drops, your LP position ends up holding more ETH and fewer USDC. For example, at 1800 USDC/ETH, let’s say your LP position now consists of:
    - 1.1 ETH and 1620 USDC (again, approximate numbers for illustration).
- Futures Position: You are short 1 ETH from 2000 USDC/ETH, and now ETH is 1800 USDC/ETH.
    - Entry price: 2000 USDC/ETH
    - Exit price: 1800 USDC/ETH
    - Profit per ETH: 2000 - 1800 = 200 USDC profit.
- You gain 200 USDC on the futures position.

#### Combine Both Outcomes at Exit:

- LP gives you: ~1.1 ETH + 1620 USDC
- Futures gives you: +200 USDC profit

Total after closing futures:

- ETH: 1.1 ETH
- USDC: 1620 + 200 = 1820 USDC

Now you have more ETH than you started with (1.1 vs. 1) and less USDC (1820 vs. 2000). Since ETH is cheaper (1800 USDC), you can sell 0.1 ETH for 180 USDC:

- Sell 0.1 ETH at 1800 USDC/ETH = 180 USDC
- Now you have:
    - ETH: 1.1 ETH - 0.1 ETH = 1 ETH
    - USDC: 1820 + 180 = 2000 USDC

**Result:** You again end up with 1 ETH and 2000 USDC, just as you started, despite the price going down.

## Conclusion

- By taking a short futures position equal to the initial amount of ETH deposited, you’ve effectively neutralized the impact of price movements on your ability to end up with your original principal.
- After closing both positions (the LP and the futures), you might initially have a different mix than you started with, but you’ll have enough value in USDC and ETH combined that you can trade back to your original desired amounts (1 ETH and 2000 USDC).
- In practice, you might need to periodically adjust the futures hedge if the price moves a lot, or choose a slightly different hedging strategy. But the principle remains: the futures position compensates for the changes in token ratios within the LP.

deSync is only a tool that helps you prevent yourself from IL, today, if you are providing liquidity to any LP, the chances that your profits are eaten up by IL is 100%, however with deSync you get the best hedge in the industry while reaping upto 100%+ APR yield on your wBTC through trading fees incentives on DEXs like Uniswap.
