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

| Executionist | Address | Upkeep Id |
| - | - | - |
| ETH Pool Executionist | [0x01D41C27B633b0B448D997156eeE5A9eF81e673B](https://sepolia.scrollscan.com/address/0x01D41C27B633b0B448D997156eeE5A9eF81e673B) | [35158478014448269563849726287131772693166253354725353425917992506841538027078](https://automation.chain.link/scroll-sepolia-testnet/35158478014448269563849726287131772693166253354725353425917992506841538027078) |
| BTC Pool Executionist | [0xf528037c638Ff73Cacc60549c09b5Aa84D57C5F0](https://sepolia.scrollscan.com/address/0xf528037c638Ff73Cacc60549c09b5Aa84D57C5F0) | [34690142626921195545890673367872234003488640505703456749029602922762788687261](https://automation.chain.link/scroll-sepolia-testnet/34690142626921195545890673367872234003488640505703456749029602922762788687261) |
| USDC Pool Executionist | [0xBEd7B33b74b6003A009adee7691BCC4394E64511](https://sepolia.scrollscan.com/address/0xBEd7B33b74b6003A009adee7691BCC4394E64511) | [9842898161169548720400045691299051437321491753995842685371276028822950430162](https://automation.chain.link/scroll-sepolia-testnet/9842898161169548720400045691299051437321491753995842685371276028822950430162) |

## Withdraw Intent Distributor Addresses

Withdraw Intent Distributors are triggered by Chainlink Automation to rebalance the pools.

| Withdraw Intent Distributor | Address | Upkeep Id |
| - | - | - |
| ETH Withdraw Distributor | [0xC9678bAD68016034181e8B55A34631Ff91E2ba96](https://sepolia.scrollscan.com/address/0xC9678bAD68016034181e8B55A34631Ff91E2ba96) | [46562794566700408181792940213623077813618253808534806896701739255414002386529](https://automation.chain.link/scroll-sepolia-testnet/46562794566700408181792940213623077813618253808534806896701739255414002386529) |
| BTC Withdraw Distributor | [0x49ea2E18816cDbdCd011cBF0401d0C8821a8b474](https://sepolia.scrollscan.com/address/0x49ea2E18816cDbdCd011cBF0401d0C8821a8b474) | [50966094743740467626994261021574989889205537359180048324577880157566123087730](https://automation.chain.link/scroll-sepolia-testnet/50966094743740467626994261021574989889205537359180048324577880157566123087730) |
| USDC Withdraw Distributor | [0xfd1B77d527fE1d7daE077ba1D7BC0153fC473F4a](https://sepolia.scrollscan.com/address/0xfd1B77d527fE1d7daE077ba1D7BC0153fC473F4a) | [64580417417782519304712693933365859629570109617157762144741932053954923897122](https://automation.chain.link/scroll-sepolia-testnet/64580417417782519304712693933365859629570109617157762144741932053954923897122) |

## Borrow Intent Distributor Addresses

Borrow Intent Distributors are triggered by Chainlink Automation to rebalance the pools.

| Borrow Intent Distributor | Address | Upkeep Id |
| - | - | - |
| ETH Borrow Distributor | [0x5Bd4bae80F7B4fde93170Ed462228f47880d189f](https://sepolia.scrollscan.com/address/0x5Bd4bae80F7B4fde93170Ed462228f47880d189f) | [87049045424493492918335076672248672668758658634006859109564612234057180179893](https://automation.chain.link/scroll-sepolia-testnet/87049045424493492918335076672248672668758658634006859109564612234057180179893) |
| BTC Borrow Distributor | [0xF76311bb777Bc00fDE091B71919Ed14738C2Ca46](https://sepolia.scrollscan.com/address/0xF76311bb777Bc00fDE091B71919Ed14738C2Ca46) | [109819078113118090549833333927707155956479456642257873268492752228503158366](https://automation.chain.link/scroll-sepolia-testnet/109819078113118090549833333927707155956479456642257873268492752228503158366) |
| USDC Borrow Distributor | [0x78211E0cAea70d63F539dfcee94F4F78714d8772](https://sepolia.scrollscan.com/address/0x78211E0cAea70d63F539dfcee94F4F78714d8772) | [33483487774596387540998586658845728895118894136202003455303516065519651344341](https://automation.chain.link/scroll-sepolia-testnet/33483487774596387540998586658845728895118894136202003455303516065519651344341) |