---
sidebar_position: 9
---

# Contract Addresses

All the contracts are deployed to Scroll Sepolia and verified on Scrollscan.

## Token Addresses

| Token | Address |
| - | - |
| ETH | [0x293ecDf92Aa331eEf8828989aC3b2861B1fC71B5](https://sepolia.scrollscan.com/address/0x293ecDf92Aa331eEf8828989aC3b2861B1fC71B5) |
| BTC | [0xE44eb78cE60EaFda5DF2a15c9f502874A62683C7](https://sepolia.scrollscan.com/address/0xE44eb78cE60EaFda5DF2a15c9f502874A62683C7) |
| USDC | [0x06C1b84fcBDc916B73C223e41BF4F628774B0168](https://sepolia.scrollscan.com/address/0x06C1b84fcBDc916B73C223e41BF4F628774B0168) |

## Clones

deSync Pools, deTokens and debtTokens are implemented as [clones](https://www.rareskills.io/post/eip-1167-minimal-proxy-standard-with-initialization-clone-pattern).

### Implementation Addresses

| Implementation | Address |
| - | - |
| Pool | [0x126a643C5f61c627Ca60735c2DBabC694057602f](https://sepolia.scrollscan.com/address/0x126a643c5f61c627ca60735c2dbabc694057602f) |
| deToken | [0x45cBb61Cb7f2819455f6AdfB96A51926c85B42dd](https://sepolia.scrollscan.com/address/0x45cbb61cb7f2819455f6adfb96a51926c85b42dd) |
| debtToken | [0x10778222073821FE78Cc3Ce089A03d5dA8cF7989](https://sepolia.scrollscan.com/address/0x10778222073821fe78cc3ce089a03d5da8cf7989) |

## Pool Addresses

Pools are clones that point to the [implementation](#implementation-addresses).

| Pool | Address |
| - | - |
| ETH Pool | [0x4e364B9F66e1f779793D594d4e6fC1d3d4B92475](https://sepolia.scrollscan.com/address/0x4e364B9F66e1f779793D594d4e6fC1d3d4B92475) |
| BTC Pool | [0x6852e6430A25fB08d7F384f3a3C258bbEf613f6A](https://sepolia.scrollscan.com/address/0x6852e6430A25fB08d7F384f3a3C258bbEf613f6A) |
| USDC Pool | [0xF77d50613B6C976fDaca69751A5363Af7dD5ecb7](https://sepolia.scrollscan.com/address/0xF77d50613B6C976fDaca69751A5363Af7dD5ecb7) |

## deToken Addresses

deTokens are clones that point to the [implementation](#implementation-addresses).

| deToken | Address |
| - | - |
| deETH | [0x4907b48a35415f3ba5fD683C4CAb87c73730dDAa](https://sepolia.scrollscan.com/address/0x4907b48a35415f3ba5fD683C4CAb87c73730dDAa) |
| deBTC | [0xdDc5F0fd1cF4Df5A38091D6360CCe94f9CcAc4B2](https://sepolia.scrollscan.com/address/0xdDc5F0fd1cF4Df5A38091D6360CCe94f9CcAc4B2) |
| deUSDC | [0x6a41920Ba5e968f3C53111cb1D7Ac5e1927F4dFC](https://sepolia.scrollscan.com/address/0x6a41920Ba5e968f3C53111cb1D7Ac5e1927F4dFC) |

## debtToken Addresses

debtTokens are clones that point to the [implementation](#implementation-addresses).

| debtToken | Address |
| - | - |
| ETHdebt | [0xca6cdf3eC2fA1b9F5Fa4abE923c174225Ff3931f](https://sepolia.scrollscan.com/address/0xca6cdf3eC2fA1b9F5Fa4abE923c174225Ff3931f) |
| BTCdebt | [0xf69c0cFdF67C5DC1FfCEE114E1B74e07AfBdFd88](https://sepolia.scrollscan.com/address/0xf69c0cFdF67C5DC1FfCEE114E1B74e07AfBdFd88) |
| USDCdebt | [0x655533a6812F6a110D6717523aAEEBe1EF874D16](https://sepolia.scrollscan.com/address/0x655533a6812F6a110D6717523aAEEBe1EF874D16) | 

## Controller Address

Controller: [0x77B7C3298cC449121fcc45c7a93B7b14FcF55E65](https://sepolia.scrollscan.com/address/0x77B7C3298cC449121fcc45c7a93B7b14FcF55E65)

## Executionist Addresses

Executionists are triggered by Chainlink Automation to rebalance the pools.

:::info
The Upkeep contracts are not verified because they are deployed by Chainlink.
:::

| Executionist | Address | Upkeep Address |
| - | - | - |
| ETH Pool Executionist | [0x01D41C27B633b0B448D997156eeE5A9eF81e673B](https://sepolia.scrollscan.com/address/0x01D41C27B633b0B448D997156eeE5A9eF81e673B) | 0xFCeB966618B7bd552623A09e7d27199432b3F58c |
| BTC Pool Executionist | [0xf528037c638Ff73Cacc60549c09b5Aa84D57C5F0](https://sepolia.scrollscan.com/address/0xf528037c638Ff73Cacc60549c09b5Aa84D57C5F0) | 0x4baE10fbEFbC30f70E68490f6E406fA8DecB0E62 |
| USDC Pool Executionist | [0xBEd7B33b74b6003A009adee7691BCC4394E64511](https://sepolia.scrollscan.com/address/0xBEd7B33b74b6003A009adee7691BCC4394E64511) | 0x2e4AAd57f9A143F29b8A16a8447D8be90a099C9C |

## Withdraw Intent Distributor Addresses

:::info
The Upkeep contracts are not verified because they are deployed by Chainlink.
:::

| Withdraw Intent Distributor | Address | Upkeep Address |
| - | - | - |
| ETH Withdraw Distributor | [0xC9678bAD68016034181e8B55A34631Ff91E2ba96](https://sepolia.scrollscan.com/address/0xC9678bAD68016034181e8B55A34631Ff91E2ba96) | 0xbCF63b5f3B1a13a3BA825BC59A8d6B950054823f |
| BTC Withdraw Distributor | [0x49ea2E18816cDbdCd011cBF0401d0C8821a8b474](https://sepolia.scrollscan.com/address/0x49ea2E18816cDbdCd011cBF0401d0C8821a8b474) | 0x38512097cE6E351daF1Ccf1f6dEa0Bb23B8C42D0 |
| USDC Withdraw Distributor | [0xfd1B77d527fE1d7daE077ba1D7BC0153fC473F4a](https://sepolia.scrollscan.com/address/0xfd1B77d527fE1d7daE077ba1D7BC0153fC473F4a) | 0xCD8FB002396a4eD0A973C348772240d454815140 |

## Borrow Intent Distributor Addresses

:::info
The Upkeep contracts are not verified because they are deployed by Chainlink.
:::

| Borrow Intent Distributor | Address | Upkeep Address |
| - | - | - |
| ETH Borrow Distributor | [0x5Bd4bae80F7B4fde93170Ed462228f47880d189f](https://sepolia.scrollscan.com/address/0x5Bd4bae80F7B4fde93170Ed462228f47880d189f) | 0x1CcD305d4d4F773Aa355C08C175A452b18C487Ff |
| BTC Borrow Distributor | [0xF76311bb777Bc00fDE091B71919Ed14738C2Ca46](https://sepolia.scrollscan.com/address/0xF76311bb777Bc00fDE091B71919Ed14738C2Ca46) | 0x546eBDb4DB8b14b4EF0208bF1dF3FD8466d8731d |
| USDC Borrow Distributor | [0x78211E0cAea70d63F539dfcee94F4F78714d8772](https://sepolia.scrollscan.com/address/0x78211E0cAea70d63F539dfcee94F4F78714d8772) | 0xE638Cb10e4f1a514a93119B47Bafb2ABf7ab9c17 |