import { getAddress } from "viem";

export const assets = [
    {
        symbol: "BTC",
        icon: "https://assets.coingecko.com/coins/images/1/small/bitcoin.png",
        address: getAddress(process.env.NEXT_PUBLIC_BTC_CONTRACT_ADDRESS!),
        poolAddress: getAddress(process.env.NEXT_PUBLIC_BTC_POOL_ADDRESS!),
        deTokenAddress: getAddress(process.env.NEXT_PUBLIC_BTC_DETOKEN_ADDRESS!),
        debtTokenAddress: getAddress(process.env.NEXT_PUBLIC_BTC_DEBTTOKEN_ADDRESS!),
        apy: 10.0,
    },
    {
        symbol: "ETH",
        icon: "https://assets.coingecko.com/coins/images/279/small/ethereum.png",
        address: getAddress(process.env.NEXT_PUBLIC_ETH_CONTRACT_ADDRESS!),
        poolAddress: getAddress(process.env.NEXT_PUBLIC_ETH_POOL_ADDRESS!),
        deTokenAddress: getAddress(process.env.NEXT_PUBLIC_ETH_DETOKEN_ADDRESS!),
        debtTokenAddress: getAddress(process.env.NEXT_PUBLIC_ETH_DEBTTOKEN_ADDRESS!),
        apy: 12.9,
    },
    {
        symbol: "USDC",
        icon: "https://assets.coingecko.com/coins/images/6319/small/USD_Coin_icon.png",
        address: getAddress(process.env.NEXT_PUBLIC_USDC_CONTRACT_ADDRESS!),
        poolAddress: getAddress(process.env.NEXT_PUBLIC_USDC_POOL_ADDRESS!),
        deTokenAddress: getAddress(process.env.NEXT_PUBLIC_USDC_DETOKEN_ADDRESS!),
        debtTokenAddress: getAddress(process.env.NEXT_PUBLIC_USDC_DEBTTOKEN_ADDRESS!),
        apy: 7.0,
    },
];

export const controllerAddress = getAddress(process.env.NEXT_PUBLIC_CONTROLLER_ADDRESS!);

export const explorerBaseUrl = process.env.NEXT_PUBLIC_EXPLORER_BASE_URL!;