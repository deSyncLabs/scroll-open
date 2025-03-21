"use client";

import { useState, useEffect, useRef } from "react";
import {
    useAccount,
    useReadContracts,
    useWriteContract,
    useWaitForTransactionReceipt,
} from "wagmi";
import { formatEther, parseEther } from "viem";
import { useQueryClient } from "@tanstack/react-query";
import { LoaderCircle, CircleCheck, ExternalLink } from "lucide-react";
import { mintableERC20ABI, poolABI } from "@/shared/abis";
import { explorerBaseUrl } from "@/shared/metadata";
import { truncateNumberToTwoDecimals, truncateAddress } from "@/lib/utils";
import { RAY } from "@/lib/utils";
import { TableRow, TableCell } from "./ui/table";
import { Button } from "./ui/button";
import { Input } from "./ui/input";
import {
    Dialog,
    DialogContent,
    DialogDescription,
    DialogHeader,
    DialogTitle,
    DialogTrigger,
    DialogFooter,
} from "./ui/dialog";
import {
    Stepper,
    StepperIndicator,
    StepperItem,
    StepperSeparator,
    StepperTitle,
} from "./ui/stepper";

type SupplyCardProps = {
    symbol: string;
    icon: string;
    tokenAddress: `0x${string}`;
    poolAddress: `0x${string}`;
};

type SupplyDialogProps = {
    step: number;
    setStep: (step: number) => void;
    symbol: string;
    account: `0x${string}`;
    tokenAddress: `0x${string}`;
    poolAddress: `0x${string}`;
};

type StepProps = {
    symbol: string;
    account: `0x${string}`;
    tokenAddress: `0x${string}`;
    poolAddress: `0x${string}`;
    transactionHash: `0x${string}` | undefined;
    setStep: (step: number) => void;
    setTransactionHash: (hash: `0x${string}` | undefined) => void;
};

export function SupplyCard({
    symbol,
    icon,
    tokenAddress,
    poolAddress,
}: SupplyCardProps) {
    const [step, setStep] = useState(1);
    const [isDialogOpen, setIsDialogOpen] = useState(false);

    const { address: account } = useAccount();

    const data = useReadContracts({
        contracts: [
            {
                address: tokenAddress,
                abi: mintableERC20ABI,
                functionName: "balanceOf",
                args: [account],
            },
            {
                address: poolAddress,
                abi: poolABI,
                functionName: "apy",
            },
        ],
    });

    const raypy =
        data.data && data.data[1].result
            ? (data.data[1].result as bigint)
            : BigInt(0);
    const apy = Number((raypy * BigInt(100)) / (RAY / BigInt(10 ** 2))) / 100;

    return (
        <TableRow>
            <TableCell>
                <div className="flex items-center space-x-3">
                    <img
                        src={icon}
                        alt={`${symbol}'s icon`}
                        className="rounded-full w-6 h-6"
                    />
                    <span>{symbol}</span>
                </div>
            </TableCell>
            <TableCell>
                {!account ? (
                    "--"
                ) : data.isFetching ? (
                    <LoaderCircle className="animate-spin" />
                ) : data.data && data.data[0].result ? (
                    truncateNumberToTwoDecimals(
                        formatEther(data.data![0].result as bigint)
                    )
                ) : (
                    "0.00"
                )}
            </TableCell>
            <TableCell>
                {data.isFetching ? (
                    <LoaderCircle className="animate-spin" />
                ) : (
                    `${truncateNumberToTwoDecimals(apy.toString())}%`
                )}
            </TableCell>
            <TableCell className="text-right">
                <Dialog
                    open={isDialogOpen}
                    onOpenChange={(open) => {
                        setIsDialogOpen(open);
                        if (!open) setStep(1);
                    }}
                >
                    <DialogTrigger asChild>
                        <Button
                            disabled={!account}
                            className="hover:cursor-pointer"
                        >
                            Supply
                        </Button>
                    </DialogTrigger>
                    <SupplyDialog
                        step={step}
                        setStep={setStep}
                        symbol={symbol}
                        account={account!}
                        tokenAddress={tokenAddress}
                        poolAddress={poolAddress}
                    />
                </Dialog>
            </TableCell>
        </TableRow>
    );
}

function SupplyDialog({
    step,
    setStep,
    symbol,
    account,
    tokenAddress,
    poolAddress,
}: SupplyDialogProps) {
    const [transactionHash, setTransactionHash] = useState<
        `0x${string}` | undefined
    >();

    const steps = [
        {
            step: 1,
            dialogTitle: `Please approve deSync to spend your ${symbol}`,
            dialogDescription: `deSync needs your approval to spend your ${symbol} on your behalf.`,
            component: ApproveStep,
            stepTitle: "Approve",
        },
        {
            step: 2,
            dialogTitle: `Supply ${symbol}`,
            dialogDescription: `Assets you supply not only earn yeild but also double as collateral.`,
            component: SupplyStep,
            stepTitle: "Supply",
        },
        {
            step: 3,
            dialogTitle: `Done`,
            dialogDescription: `You have successfully supplied ${symbol}.`,
            component: DoneStep,
            stepTitle: "Done",
        },
    ];

    const currentStep = steps.find((item) => item.step === step);

    return (
        <DialogContent className="font-[family-name:var(--font-geist-mono)] ">
            {(currentStep?.dialogTitle || currentStep?.dialogDescription) && (
                <>
                    <DialogHeader>
                        {currentStep.dialogTitle && (
                            <DialogTitle>{currentStep.dialogTitle}</DialogTitle>
                        )}
                        {currentStep.dialogDescription && (
                            <DialogDescription>
                                {currentStep.dialogDescription}
                            </DialogDescription>
                        )}
                    </DialogHeader>

                    <currentStep.component
                        symbol={symbol}
                        account={account}
                        tokenAddress={tokenAddress}
                        poolAddress={poolAddress}
                        setStep={setStep}
                        transactionHash={transactionHash}
                        setTransactionHash={setTransactionHash}
                    />
                </>
            )}

            <DialogFooter>
                <Stepper className="flex justify-between" value={step}>
                    {steps.map(({ step, stepTitle: title }) => (
                        <StepperItem step={step} key={step} className="">
                            <div className="flex items-center gap-2">
                                <StepperIndicator>{step}</StepperIndicator>
                                <StepperTitle>{title}</StepperTitle>
                            </div>

                            {step < steps.length && (
                                <StepperSeparator className="max-md:mt-3.5 md:mx-4" />
                            )}
                        </StepperItem>
                    ))}
                </Stepper>
            </DialogFooter>
        </DialogContent>
    );
}

function ApproveStep({
    account,
    tokenAddress,
    poolAddress,
    setStep,
}: StepProps) {
    const MAX_ALLOWANCE = BigInt(
        "115792089237316195423570985008687907853269984665640564039457584007913129639935"
    );

    const isMounted = useRef(true);

    const [approving, setApproving] = useState(false);
    const [error, setError] = useState<string | null>(null);

    const data = useReadContracts({
        contracts: [
            {
                address: tokenAddress,
                abi: mintableERC20ABI,
                functionName: "allowance",
                args: [account, poolAddress],
            },
        ],
    });

    const approve = useWriteContract({
        mutation: {
            onMutate: () => {
                setError(null);
                setApproving(true);
            },
            onError: ({ name }) => {
                setError(name);
                setApproving(false);
            },
        },
    });

    const receipt = useWaitForTransactionReceipt({ hash: approve.data });

    useEffect(() => {
        if (receipt.status === "success") {
            setApproving(false);
            setStep(2);
        } else if (receipt.status === "error") {
            setApproving(false);

            if (receipt.error) setError(receipt.error.name);
        }
    }, [receipt.status]);

    async function handleApprove() {
        try {
            await approve.writeContractAsync({
                abi: mintableERC20ABI,
                address: tokenAddress,
                functionName: "approve",
                args: [poolAddress, MAX_ALLOWANCE],
            });
        } catch (error) {
            console.log(error);
        }
    }

    useEffect(() => {
        if (
            data.data &&
            data.data[0].result &&
            (data.data[0].result as bigint) >= MAX_ALLOWANCE &&
            isMounted.current
        ) {
            setStep(2);
        }
    }, [data.data, setStep]);

    if (data.isFetching) return <LoaderCircle className="animate-spin" />;

    return (
        <div className="flex flex-col items-center gap-4">
            <Button
                onClick={handleApprove}
                className="w-full hover:cursor-pointer"
                disabled={approving}
            >
                {approving ? (
                    <LoaderCircle className="animate-spin" />
                ) : (
                    "Approve"
                )}
            </Button>

            {error && <div className="text-red-500">{error}</div>}
        </div>
    );
}

function SupplyStep({
    account,
    tokenAddress,
    poolAddress,
    setStep,
    setTransactionHash,
}: StepProps) {
    const [amount, setAmount] = useState<string>("");
    const [validAmount, setValidAmount] = useState(false);
    const [supplying, setSupplying] = useState(false);
    const [error, setError] = useState<string | null>(null);

    const queryClient = useQueryClient();

    const data = useReadContracts({
        contracts: [
            {
                address: tokenAddress,
                abi: mintableERC20ABI,
                functionName: "balanceOf",
                args: [account],
            },
        ],
    });

    useEffect(() => {
        if (data.data && data.data[0].result) {
            const balance = formatEther(data.data[0].result as bigint);
            if (Number(amount) > Number(balance)) {
                setValidAmount(false);
            } else if (Number(amount) <= 0) {
                setValidAmount(false);
            } else {
                setValidAmount(true);
            }
        }
    }, [amount, data.data]);

    const supply = useWriteContract({
        mutation: {
            onMutate: () => {
                setError(null);
                setSupplying(true);
            },
            onError: ({ name }) => {
                setError(name);
                setSupplying(false);
            },
        },
    });

    const receipt = useWaitForTransactionReceipt({ hash: supply.data });

    useEffect(() => {
        if (receipt.status === "success") {
            setSupplying(false);
            setTransactionHash(supply.data);
            queryClient.invalidateQueries();
            setStep(3);
        } else if (receipt.status === "error") {
            setSupplying(false);

            if (receipt.error) setError(receipt.error.name);
        }
    }, [receipt.status]);

    function handleValueChange(e: React.ChangeEvent<HTMLInputElement>) {
        const value = e.target.value;

        if (value === "") {
            setAmount(value);
            return;
        }

        const numValue = Number(value);
        if (numValue < 0) return;

        setAmount(value);
    }

    function handleMax() {
        if (data.data && data.data[0].result) {
            setAmount(formatEther(data.data[0].result as bigint));
        }
    }

    async function handleSupply() {
        try {
            await supply.writeContractAsync({
                abi: poolABI,
                address: poolAddress,
                functionName: "deposit",
                args: [parseEther(amount)],
            });
        } catch (error) {
            console.log(error);
        }
    }

    return (
        <div className="flex flex-col items-center gap-4">
            <div className="w-full flex space-x-1">
                <span className="text-muted-foreground">Your Balance: </span>
                <span>
                    {data.isFetching ? (
                        <LoaderCircle className="animate-spin" />
                    ) : data.data && data.data[0].result ? (
                        truncateNumberToTwoDecimals(
                            formatEther(data.data[0].result as bigint)
                        )
                    ) : (
                        "0.00"
                    )}
                </span>
            </div>

            <div className="flex space-x-2 w-full">
                <Input
                    value={amount}
                    type="number"
                    onChange={handleValueChange}
                />
                <Button
                    variant={"secondary"}
                    className="hover:cursor-pointer"
                    disabled={data.isFetching}
                    onClick={handleMax}
                >
                    Max
                </Button>
            </div>

            <Button
                className="w-full hover:cursor-pointer"
                disabled={data.isFetching || !validAmount || supplying}
                onClick={handleSupply}
            >
                {supplying ? (
                    <LoaderCircle className="animate-spin" />
                ) : (
                    "Supply"
                )}
            </Button>

            {error && <div className="text-red-500">{error}</div>}
        </div>
    );
}

function DoneStep({ transactionHash }: StepProps) {
    return (
        <div className="flex flex-col items-center gap-2">
            <CircleCheck className="stroke-green-500" size={50} />

            <p className="text-muted-foreground text-lg text-center">
                Your transactoin was successful.
            </p>

            {transactionHash && (
                <a
                    href={`${explorerBaseUrl}/tx/${transactionHash}`}
                    target="_blank"
                    rel="noopener noreferrer"
                    className="text-muted-foreground hover:text-foreground transition-colors flex items-center gap-1"
                >
                    <span>{truncateAddress(transactionHash!)}</span>
                    <ExternalLink size={16} />
                </a>
            )}
        </div>
    );
}
