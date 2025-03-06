"use client";

import { useState } from "react";
import { useAccount, useReadContracts } from "wagmi";
import { formatEther } from "viem";
import { LoaderCircle } from "lucide-react";
import { poolABI } from "@/shared/abis";
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
    poolAddress: `0x${string}`;
};

type BorrowDialogProps = {
    step: number;
    setStep: (step: number) => void;
    symbol: string;
    account: string;
    poolAddress: `0x${string}`;
};

type StepProps = {
    symbol: string;
    account: string;
    poolAddress: `0x${string}`;
    setStep: (step: number) => void;
};

export function BorrowCard({ symbol, icon, poolAddress }: BorrowCardProps) {
    const [step, setStep] = useState(1);
    const [isDialogOpen, setIsDialogOpen] = useState(false);

    const { address: account } = useAccount();

    const data = useReadContracts({
        contracts: [
            {
                address: poolAddress,
                abi: poolABI,
                functionName: "balance",
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
                {data.isFetching ? (
                    <LoaderCircle className="animate-spin" />
                ) : data.data && data.data[0].result ? (
                    formatEther(data.data![0].result as bigint)
                ) : (
                    "0"
                )}
            </TableCell>
            <TableCell>0%</TableCell>
            <TableCell className="text-right">
                <Dialog
                    open={isDialogOpen}
                    onOpenChange={(open) => {
                        setIsDialogOpen(open);
                        if (!open) setStep(1);
                    }}
                >
                    <DialogTrigger asChild>
                        <Button className="hover:cursor-pointer">Borrow</Button>
                    </DialogTrigger>
                    <BorrowDialog
                        step={step}
                        setStep={setStep}
                        symbol={symbol}
                        account={account!}
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
    poolAddress,
}: BorrowDialogProps) {
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

function BorrowStep({ setStep }: StepProps) {
    const [amount, setAmount] = useState<string>("");
    const [validAmount, setValidAmount] = useState(false);
    const [borrowing, setBorrowing] = useState(false);
    const [error, setError] = useState<string | null>(null);

    const data = useReadContracts({});

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

    // function handleMax() {
    //     if (data.data && data.data[0].result) {
    //         setAmount(formatEther(data.data[0].result as bigint));
    //     }
    // }

    async function handleBorrow() {}

    return (
        <div className="flex flex-col items-center gap-4">
            <div className="flex space-x-2 w-full">
                <Input
                    value={amount}
                    type="number"
                    onChange={handleValueChange}
                />
                {/* <Button
                    variant={"secondary"}
                    className="hover:cursor-pointer"
                    disabled={data.isFetching}
                    onClick={handleMax}
                >
                    Max
                </Button> */}
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

function DoneStep({ setStep }: StepProps) {
    return <div></div>;
}
