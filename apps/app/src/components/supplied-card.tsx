"use client";

import { useState, useEffect } from "react";
import {
    useAccount,
    useReadContracts,
    useWriteContract,
    useWaitForTransactionReceipt,
} from "wagmi";
import { formatEther, parseEther } from "viem";
import { LoaderCircle, Clock } from "lucide-react";
import { deTokenABI, poolABI } from "@/shared/abis";
import { Button } from "./ui/button";
import { Input } from "./ui/input";
import { TableRow, TableCell } from "./ui/table";
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

type SuppliedCardProps = {
    symbol: string;
    icon: string;
    deTokenAddress: `0x${string}`;
    poolAddress: `0x${string}`;
};

type WithdrawDialogProps = {
    step: number;
    setStep: (step: number) => void;
    symbol: string;
    account: string;
    deTokenAddress: `0x${string}`;
    poolAddress: `0x${string}`;
};

type StepProps = {
    symbol: string;
    account: string;
    deTokenAddress: `0x${string}`;
    poolAddress: `0x${string}`;
    setStep: (step: number) => void;
};

export function SuppliedCard({
    symbol,
    icon,
    deTokenAddress,
    poolAddress,
}: SuppliedCardProps) {
    const [step, setStep] = useState(1);
    const [isDialogOpen, setIsDialogOpen] = useState(false);

    const { address: account } = useAccount();

    const data = useReadContracts({
        contracts: [
            {
                address: deTokenAddress,
                abi: deTokenABI,
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

    const RAY = BigInt(10 ** 27);
    const raypy =
        data.data && data.data[1].result
            ? (data.data[1].result as bigint)
            : BigInt(0);
    const apy = Number((raypy * BigInt(100)) / RAY);

    if (data.isFetching) {
        return (
            <TableRow>
                <TableCell>
                    <div>
                        <LoaderCircle className="animate-spin" />
                    </div>
                </TableCell>
            </TableRow>
        );
    }

    if (data.data && !data.data[0].result) {
        return null;
    }

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
                {data.isFetching ? (
                    <LoaderCircle className="animate-spin" />
                ) : data.data && data.data[0].result ? (
                    formatEther(data.data![0].result as bigint)
                ) : (
                    "0"
                )}
            </TableCell>
            <TableCell>{apy.toString()}%</TableCell>
            <TableCell className="text-right">
                <Dialog
                    open={isDialogOpen}
                    onOpenChange={(open) => {
                        setIsDialogOpen(open);
                    }}
                >
                    <DialogTrigger asChild>
                        <Button className="hover:cursor-pointer">
                            Withdraw
                        </Button>
                    </DialogTrigger>
                    <WithdrawDialog
                        step={step}
                        setStep={setStep}
                        symbol={symbol}
                        account={account!}
                        deTokenAddress={deTokenAddress}
                        poolAddress={poolAddress}
                    />
                </Dialog>
            </TableCell>
        </TableRow>
    );
}

function WithdrawDialog({
    step,
    setStep,
    symbol,
    account,
    deTokenAddress,
    poolAddress,
}: WithdrawDialogProps) {
    const steps = [
        {
            step: 1,
            dialogTitle: `Withdraw ${symbol}`,
            dialogDescription: `Withdraw your ${symbol} from the pool`,
            component: WithdrawStep,
            stepTitle: "Withdraw",
        },
        {
            step: 2,
            dialogTitle: "Done",
            dialogDescription: "Withdraw intent has been submitted",
            component: DoneStep,
            stepTitle: "Done",
        },
    ];

    const currentStep = steps.find((item) => item.step === step);

    return (
        <DialogContent>
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
                        deTokenAddress={deTokenAddress}
                        poolAddress={poolAddress}
                        setStep={setStep}
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

function WithdrawStep({
    symbol,
    account,
    deTokenAddress,
    poolAddress,
    setStep,
}: StepProps) {
    const [amount, setAmount] = useState<string>("");
    const [validAmount, setValidAmount] = useState(false);
    const [withdrawing, setWithdrawing] = useState(false);
    const [error, setError] = useState<string | null>(null);

    const data = useReadContracts({
        contracts: [
            {
                address: deTokenAddress,
                abi: deTokenABI,
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

    const withdraw = useWriteContract({
        mutation: {
            onMutate: () => {
                setError(null);
                setWithdrawing(true);
            },
            onError: ({ name }) => {
                setError(name);
                setWithdrawing(false);
            },
        },
    });

    const receipt = useWaitForTransactionReceipt({ hash: withdraw.data });

    useEffect(() => {
        if (receipt.status === "success") {
            setWithdrawing(false);
            setStep(2);
        } else if (receipt.status === "error") {
            setWithdrawing(false);

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
            setAmount(formatEther(data.data[0].result as bigint));
        }
    }

    async function handleWithdraw() {
        try {
            await withdraw.writeContractAsync({
                abi: poolABI,
                address: poolAddress,
                functionName: "unlock",
                args: [parseEther(amount)],
            });
        } catch (error) {}
    }

    return (
        <div className="flex flex-col items-center gap-4">
            <div className="w-full flex space-x-1">
                <span className="text-muted-foreground">Your Balance: </span>
                <span>
                    {data.isFetching ? (
                        <LoaderCircle className="animate-spin" />
                    ) : data.data && data.data[0].result ? (
                        formatEther(data.data[0].result as bigint)
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
                disabled={data.isFetching || !validAmount || withdrawing}
                onClick={handleWithdraw}
            >
                {withdrawing ? (
                    <LoaderCircle className="animate-spin" />
                ) : (
                    "Withdraw"
                )}
            </Button>

            {error && <div className="text-red-500">{error}</div>}
        </div>
    );
}

function DoneStep(_: StepProps) {
    return (
        <div className="flex flex-col items-center gap-2">
            <Clock className="stroke-green-500" size={50} />
            <p className="text-muted-foreground text-lg text-center">
                Please wait upto 24 hours for your funds to be unlocked
            </p>
        </div>
    );
}
