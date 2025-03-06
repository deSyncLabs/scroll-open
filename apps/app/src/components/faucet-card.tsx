"use client";

import { useState, useEffect } from "react";
import {
    useAccount,
    useReadContracts,
    useWriteContract,
    useWaitForTransactionReceipt,
} from "wagmi";
import { formatEther } from "viem";
import { LoaderCircle } from "lucide-react";
import { mintableERC20ABI } from "@/shared/abis";
import { truncateAddress } from "@/lib/utils";
import { Button } from "./ui/button";

type FaucetCardProps = {
    symbol: string;
    icon: string;
    address: `0x${string}`;
};

type TimeLeft = {
    hours: string;
    minutes: string;
    seconds: string;
};

export function FaucetCard({ symbol, icon, address }: FaucetCardProps) {
    const [minting, setMinting] = useState(false);
    const [error, setError] = useState<string | null>(null);
    const [timeLeft, setTimeLeft] = useState<TimeLeft | null>(null);
    const [currentTime, setCurrentTime] = useState(
        Math.floor(Date.now() / 1000)
    );

    const { address: account } = useAccount();

    const data = useReadContracts({
        contracts: [
            {
                address: address,
                abi: mintableERC20ABI,
                functionName: "lastMintedTimestamp",
                args: [account],
            },
            {
                address: address,
                abi: mintableERC20ABI,
                functionName: "mintAmount",
            },
            {
                address: address,
                abi: mintableERC20ABI,
                functionName: "balanceOf",
                args: [account],
            },
        ],
    });

    const mint = useWriteContract({
        mutation: {
            onMutate: () => {
                setError(null);
                setMinting(true);
            },
            onError: ({ name }) => {
                setError(name);
                setMinting(false);
            },
        },
    });

    const receipt = useWaitForTransactionReceipt({
        hash: mint.data,
    });

    useEffect(() => {
        if (receipt.status === "success") {
            data.refetch();
            setMinting(false);
        } else if (receipt.status === "error") {
            setMinting(false);

            if (receipt.error) setError(receipt.error.name);
        }
    }, [receipt.status]);

    function getTimeLeft(lastTimestamp: bigint) {
        const secondsInADay = 24 * 60 * 60;
        const nextTimestamp = Number(lastTimestamp) + secondsInADay;

        if (currentTime < nextTimestamp) {
            const diff = nextTimestamp - currentTime;
            const hours = Math.floor(diff / 3600);
            const minutes = Math.floor((diff % 3600) / 60);
            const seconds = Math.floor(diff % 60);

            return {
                hours: hours.toString().padStart(2, "0"),
                minutes: minutes.toString().padStart(2, "0"),
                seconds: seconds.toString().padStart(2, "0"),
            };
        }
        return null;
    }

    useEffect(() => {
        const timer = setInterval(() => {
            setCurrentTime(Math.floor(Date.now() / 1000));
        }, 1000);
        return () => clearInterval(timer);
    }, []);

    useEffect(() => {
        if (data.data) {
            const lastTimestamp = data.data[0].result as bigint;
            const newTimeLeft = getTimeLeft(lastTimestamp);
            setTimeLeft(newTimeLeft);
        }
    }, [currentTime, data.data]);

    async function handleMint() {
        try {
            await mint.writeContractAsync({
                abi: mintableERC20ABI,
                address: address as `0x${string}`,
                functionName: "mint",
            });
        } catch (error) {}
    }

    return (
        <div className="border rounded-sm p-4 flex flex-col space-y-4">
            <div className="flex items-center space-x-4">
                <div>
                    <picture>
                        <img src={icon} alt="" />
                    </picture>
                </div>

                <div className="flex flex-col">
                    <h2 className="font-semibold text-lg">{symbol}</h2>

                    <p className="font-normal text-muted-foreground text-sm">
                        {truncateAddress(address)}
                    </p>
                </div>
            </div>

            <div className="w-full">
                <div>
                    <p className="text-muted-foreground flex space-x-1">
                        <span>{timeLeft ? "Mint In: " : "Mint: "}</span>
                        <span className="text-foreground font-medium flex space-x-1">
                            {data.isFetching ? (
                                <LoaderCircle className="animate-spin text-sm" />
                            ) : timeLeft ? (
                                <span>
                                    <span>{timeLeft.hours}</span>
                                    <span className="text-muted-foreground">
                                        h
                                    </span>{" "}
                                    <span>{timeLeft.minutes}</span>
                                    <span className="text-muted-foreground">
                                        m
                                    </span>{" "}
                                    <span>{timeLeft.seconds}</span>
                                    <span className="text-muted-foreground">
                                        s
                                    </span>
                                </span>
                            ) : (
                                <span>Now</span>
                            )}
                        </span>
                    </p>
                </div>

                <div>
                    <p className="text-muted-foreground flex space-x-1">
                        <span>Mint Amount: </span>
                        <span className="text-foreground font-medium">
                            {data.isFetching ? (
                                <LoaderCircle className="animate-spin text-sm" />
                            ) : (
                                formatEther(data.data![1].result as bigint)
                            )}
                        </span>
                    </p>
                </div>

                <div>
                    <p className="text-muted-foreground flex space-x-1">
                        <span>Your Balance: </span>
                        <span className="text-foreground font-medium">
                            {data.isFetching ? (
                                <LoaderCircle className="animate-spin text-sm" />
                            ) : data.data && data.data[2].result ? (
                                formatEther(data.data![2].result as bigint)
                            ) : (
                                "0"
                            )}
                        </span>
                    </p>
                </div>
            </div>

            <div className="w-full">
                <Button
                    className="w-full hover:cursor-pointer"
                    onClick={handleMint}
                    disabled={timeLeft !== null || minting || data.isFetching}
                >
                    {minting ? (
                        <LoaderCircle className="animate-spin" />
                    ) : (
                        "Mint"
                    )}
                </Button>
            </div>

            {error && (
                <div className="text-red-500 text-sm font-normal flex justify-center">
                    {error}
                </div>
            )}
        </div>
    );
}
