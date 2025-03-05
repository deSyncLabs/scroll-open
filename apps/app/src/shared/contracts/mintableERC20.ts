import { getAddress } from "viem";
import { mintableERC20ABI } from "@/shared/abis";

export const BTCContract = {
    address: getAddress(process.env.NEXT_PUBLIC_BTC_CONTRACT_ADDRESS!),
    abi: mintableERC20ABI,
} as const;

export const ETHContract = {
    address: getAddress(process.env.NEXT_PUBLIC_ETH_CONTRACT_ADDRESS!),
    abi: mintableERC20ABI,
} as const;

export const USDCContract = {
    address: getAddress(process.env.NEXT_PUBLIC_USDC_CONTRACT_ADDRESS!),
    abi: mintableERC20ABI,
} as const;
