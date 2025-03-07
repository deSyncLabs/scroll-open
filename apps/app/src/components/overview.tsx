"use client";

import { useAccount, useReadContracts } from "wagmi";
import { formatEther } from "viem";
import {
    DollarSign,
    HandCoins,
    Heart,
    LoaderCircle,
    Info,
    HelpCircle,
    Infinity,
} from "lucide-react";
import { controllerABI } from "@/shared/abis";
import { controllerAddress } from "@/shared/metadata";
import { RAY, cn } from "@/lib/utils";
import {
    Tooltip,
    TooltipContent,
    TooltipProvider,
    TooltipTrigger,
} from "@/components/ui/tooltip";
import { truncateNumberToTwoDecimals } from "@/lib/utils";

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
    const healthFactor = rayhfactor / RAY;

    return (
        <div className="border rounded-lg grid grid-cols-3 divide-x">
            <div className="p-4 flex justify-between items-center">
                <div>
                    <p className="text-muted-foreground text-lg flex items-center space-x-2">
                        <span>Collateral</span>

                        <TooltipProvider>
                            <Tooltip>
                                <TooltipTrigger>
                                    <HelpCircle
                                        size={12}
                                        className="fill-muted"
                                    />
                                </TooltipTrigger>

                                <TooltipContent>
                                    <p>
                                        Displayed amounts may differ as
                                        rebalancing can take up to 24 hours.
                                    </p>
                                </TooltipContent>
                            </Tooltip>
                        </TooltipProvider>
                    </p>
                    <p className="text-2xl flex">
                        <span className="text-muted-foreground">$</span>
                        {data.isFetching ? (
                            <LoaderCircle className="animate-spin" size={32} />
                        ) : data.data && data.data[0].result ? (
                            `${truncateNumberToTwoDecimals(formatEther(data.data[0].result as bigint))}`
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
                    <p className="text-muted-foreground text-lg flex items-center space-x-2">
                        <span>Borrowed Amount</span>

                        <TooltipProvider>
                            <Tooltip>
                                <TooltipTrigger>
                                    <HelpCircle
                                        size={12}
                                        className="fill-muted"
                                    />
                                </TooltipTrigger>

                                <TooltipContent>
                                    <p>
                                        Displayed amounts may differ as
                                        rebalancing can take up to 24 hours.
                                    </p>
                                </TooltipContent>
                            </Tooltip>
                        </TooltipProvider>
                    </p>
                    <p className="text-2xl flex">
                        <span className="text-muted-foreground">$</span>
                        {data.isFetching ? (
                            <LoaderCircle className="animate-spin" size={32} />
                        ) : data.data && data.data[1].result ? (
                            `${truncateNumberToTwoDecimals(formatEther(data.data[1].result as bigint))}`
                        ) : (
                            "0.00"
                        )}
                    </p>
                </div>

                <div className="bg-muted p-2 rounded-lg">
                    <HandCoins />
                </div>
            </div>

            <div className="p-4 flex justify-between items-center">
                <div>
                    <p className="text-muted-foreground text-lg flex items-center space-x-2">
                        <span>Health Factor</span>

                        <TooltipProvider>
                            <Tooltip>
                                <TooltipTrigger asChild>
                                    <Info size={12} className="fill-muted" />
                                </TooltipTrigger>

                                <TooltipContent>
                                    <p>
                                        The Health Factor measures the safety of
                                        your borrowing position. If it drops
                                        below 1, your collateral may be at risk
                                        of liquidation.
                                    </p>
                                </TooltipContent>
                            </Tooltip>
                        </TooltipProvider>
                    </p>
                    <p
                        className={cn(
                            "text-2xl",
                            healthFactor < 1.5 && "text-yellow-500",
                            healthFactor < 1 && "text-red-500"
                        )}
                    >
                        {data.isFetching ? (
                            <LoaderCircle
                                className="animate-spin stroke-foreground"
                                size={32}
                            />
                        ) : data.data && data.data[2].result ? (
                            healthFactor > 100 ? (
                                <Infinity size={32} />
                            ) : (
                                truncateNumberToTwoDecimals(
                                    healthFactor.toString()
                                )
                            )
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
