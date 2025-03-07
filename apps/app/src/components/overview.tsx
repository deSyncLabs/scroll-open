"use client";

import { useAccount, useReadContracts } from "wagmi";
import { formatEther } from "viem";
import { DollarSign, HandCoins, Heart, LoaderCircle } from "lucide-react";
import { controllerABI } from "@/shared/abis";
import { controllerAddress } from "@/shared/metadata";
import { RAY, cn } from "@/lib/utils";

export function Overview() {
    const { address: account } = useAccount();

    const data = useReadContracts({
        contracts: [
            {
                address: controllerAddress,
                abi: controllerABI,
                functionName: "totalCollateralOfInUSD",
                args: [account],
            },
            {
                address: controllerAddress,
                abi: controllerABI,
                functionName: "totalDebtOfInUSD",
                args: [account],
            },
            {
                address: controllerAddress,
                abi: controllerABI,
                functionName: "healthFactorFor",
                args: [account],
            },
        ],
    });

    const rayhfactor =
        data.data && data.data[2].result
            ? (data.data[2].result as bigint)
            : BigInt(0);
    const healthFactor = Number(rayhfactor / RAY);

    return (
        <div className="border rounded-lg grid grid-cols-3 divide-x">
            <div className="p-4 flex justify-between items-center">
                <div>
                    <p className="text-muted-foreground text-lg">Collateral</p>
                    <p className="text-2xl flex">
                        <span className="text-muted-foreground">$</span>
                        {data.isFetching ? (
                            <LoaderCircle className="animate-spin" size={32} />
                        ) : data.data && data.data[0].result ? (
                            `${Number(formatEther(data.data[0].result as bigint)).toFixed(2)}`
                        ) : (
                            "0.00"
                        )}
                    </p>
                </div>

                <div className="bg-muted p-2 rounded-lg">
                    <DollarSign />
                </div>
            </div>

            <div className="p-4 flex justify-between items-center">
                <div>
                    <p className="text-muted-foreground text-lg">
                        Borrowed Amount
                    </p>
                    <p className="text-2xl flex">
                        <span className="text-muted-foreground">$</span>
                        {data.isFetching ? (
                            <LoaderCircle className="animate-spin" size={32} />
                        ) : data.data && data.data[1].result ? (
                            `${Number(formatEther(data.data[1].result as bigint)).toFixed(2)}`
                        ) : (
                            "0.00"
                        )}
                    </p>
                </div>

                <div className="bg-muted p-2 rounded-lg">
                    <HandCoins />
                </div>
            </div>

            {/* TODO: Add "i" button */}
            <div className="p-4 flex justify-between items-center">
                <div>
                    <p className="text-muted-foreground text-lg">
                        Health Factor
                    </p>
                    <p
                        className={cn(
                            "text-2xl",
                            healthFactor < 1.5 && "text-yellow-500",
                            healthFactor < 1 && "text-red-500"
                        )}
                    >
                        {data.isFetching ? (
                            <LoaderCircle className="animate-spin" size={32} />
                        ) : data.data && data.data[2].result ? (
                            healthFactor.toFixed(2)
                        ) : (
                            "0.00"
                        )}
                    </p>
                </div>

                <div className="bg-muted p-2 rounded-lg">
                    <Heart />
                </div>
            </div>
        </div>
    );
}
