import { clsx, type ClassValue } from "clsx";
import { twMerge } from "tailwind-merge";

export function cn(...inputs: ClassValue[]) {
    return twMerge(clsx(inputs));
}

export function truncateAddress(address: `0x${string}`) {
    return `${address.slice(0, 6)}•••${address.slice(-4)}`;
}

export function truncateNumberToTwoDecimals(number: string) {
    const [integer, decimal] = number.split(".");

    if (!decimal) return `${integer}.00`;
    if (decimal.length < 2) return `${integer}.${decimal}0`;
    return `${integer}.${decimal.slice(0, 2)}`;
}

export const RAY = BigInt(10 ** 27);
