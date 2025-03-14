"use client";

import { useState, useEffect } from "react";
import {
    useAccount,
    useReadContracts,
    useWriteContract,
    useWaitForTransactionReceipt,
} from "wagmi";
import { formatEther, parseEther } from "viem";
import { useQueryClient } from "@tanstack/react-query";
import { LoaderCircle, Clock, ExternalLink } from "lucide-react";
import { controllerAddress, explorerBaseUrl } from "@/shared/metadata";
import { poolABI, controllerABI } from "@/shared/abis";
import { truncateNumberToTwoDecimals, truncateAddress } from "@/lib/utils";
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

type BorrowCardProps = {
    symbol: string;
    icon: string;
    tokenAddress: `0x${string}`;
    poolAddress: `0x${string}`;
};

type BorrowDialogProps = {
    step: number;
    setStep: (step: number) => void;
    symbol: string;
    account: string;
    tokenAddress: `0x${string}`;
    poolAddress: `0x${string}`;
};

type StepProps = {
    symbol: string;
    account: string;
    tokenAddress: `0x${string}`;
    poolAddress: `0x${string}`;
    transactionHash: `0x${string}` | undefined;
    setStep: (step: number) => void;
    setTransactionHash: (hash: `0x${string}` | undefined) => void;
};

export function BorrowCard({
    symbol,
    icon,
    tokenAddress,
    poolAddress,
}: BorrowCardProps) {
    const [step, setStep] = useState(1);
    const [isDialogOpen, setIsDialogOpen] = useState(false);

    const { address: account } = useAccount();

    const data = useReadContracts({
        contracts: [
            {
                address: poolAddress,
                abi: poolABI,
                functionName: "amountCanBoorrow",
                args: [account],
            },
        ],
    });

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
                        (
                            Number(formatEther(data.data[0].result as bigint)) *
                            0.9
                        ).toString()
                    )
                ) : (
                    "0.00"
                )}
            </TableCell>
            <TableCell>0.00%</TableCell>
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
                            Borrow
                        </Button>
                    </DialogTrigger>
                    <BorrowDialog
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

function BorrowDialog({
    step,
    setStep,
    symbol,
    account,
    tokenAddress,
    poolAddress,
}: BorrowDialogProps) {
    const [transactionHash, setTransactionHash] = useState<
        `0x${string}` | undefined
    >();

    const steps = [
        {
            step: 1,
            dialogTitle: `Borrow ${symbol}`,
            dialogDescription: `Enter the amount of ${symbol} you want to borrow.`,
            component: BorrowStep,
            stepTitle: "Borrow",
        },
        {
            step: 2,
            dialogTitle: `Done`,
            dialogDescription: "Borrow intent has been submitted.",
            component: DoneStep,
            stepTitle: "Done",
        },
    ];

    const currentStep = steps.find((item) => item.step === step);

    return (
        <DialogContent className="font-[family-name:var(--font-geist-mono)]">
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
                        transactionHash={transactionHash}
                        setStep={setStep}
                        setTransactionHash={setTransactionHash}
                    />
                </>
            )}

            <DialogFooter>
                <Stepper className="flex justify-center gap-4" value={step}>
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

function BorrowStep({
    setStep,
    setTransactionHash,
    account,
    poolAddress,
    tokenAddress,
}: StepProps) {
    const [amount, setAmount] = useState<string>("");
    const [validAmount, setValidAmount] = useState(false);
    const [borrowing, setBorrowing] = useState(false);
    const [error, setError] = useState<string | null>(null);

    const queryClient = useQueryClient();

    const data = useReadContracts({
        contracts: [
            {
                address: poolAddress,
                abi: poolABI,
                functionName: "amountCanBoorrow",
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

    const borrow = useWriteContract({
        mutation: {
            onMutate: () => {
                setError(null);
                setBorrowing(true);
            },
            onError: ({ name }) => {
                setError(name);
                setBorrowing(false);
            },
        },
    });

    const receipt = useWaitForTransactionReceipt({ hash: borrow.data });

    useEffect(() => {
        if (receipt.status === "success") {
            setBorrowing(false);
            setTransactionHash(borrow.data);
            queryClient.invalidateQueries();
            setStep(2);
        } else if (receipt.status === "error") {
            setBorrowing(false);

            console.log(receipt.error);

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
            const borrowableMax = formatEther(data.data[0].result as bigint);
            const max = Number(borrowableMax) * 0.9;

            setAmount(max.toString());
        }
    }

    async function handleBorrow() {
        try {
            await borrow.writeContractAsync({
                address: controllerAddress,
                abi: controllerABI,
                functionName: "borrow",
                args: [tokenAddress, parseEther(amount)],
            });
        } catch (error) {
            console.error(error);
        }
    }

    return (
        <div className="flex flex-col items-center gap-4">
            <div className="w-full flex space-x-1">
                <span className="text-muted-foreground">You Can Borrow: </span>
                <span>
                    {data.isFetching ? (
                        <LoaderCircle className="animate-spin" />
                    ) : data.data && data.data[0].result ? (
                        truncateNumberToTwoDecimals(
                            (
                                Number(
                                    formatEther(data.data[0].result as bigint)
                                ) * 0.9
                            ).toString()
                        )
                    ) : (
                        "0"
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
                disabled={data.isFetching || !validAmount || borrowing}
                onClick={handleBorrow}
            >
                {borrowing ? (
                    <LoaderCircle className="animate-spin" />
                ) : (
                    "Borrow"
                )}
            </Button>

            {error && <div className="text-red-500">{error}</div>}
        </div>
    );
}

function DoneStep({ transactionHash }: StepProps) {
    return (
        <div className="flex flex-col items-center gap-2">
            <Clock className="stroke-green-500" size={50} />

            <p className="text-muted-foreground text-lg text-center">
                Please wait upto 24 hours for your funds to be available.
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
