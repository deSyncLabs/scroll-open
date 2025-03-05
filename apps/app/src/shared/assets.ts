import { getAddress } from "viem";

export const assets = [
    {
        symbol: "BTC",
        icon: "https://assets.coingecko.com/coins/images/1/small/bitcoin.png",
        address: getAddress(process.env.NEXT_PUBLIC_BTC_CONTRACT_ADDRESS!),
        apy: 10.0,
    },
    {
        symbol: "ETH",
        icon: "https://assets.coingecko.com/coins/images/279/small/ethereum.png",
        address: getAddress(process.env.NEXT_PUBLIC_ETH_CONTRACT_ADDRESS!),
        apy: 12.9,
    },
    {
        symbol: "USDC",
        icon: "https://assets.coingecko.com/coins/images/6319/small/USD_Coin_icon.png",
        address: getAddress(process.env.NEXT_PUBLIC_USDC_CONTRACT_ADDRESS!),
        apy: 7.0,
    },
];
