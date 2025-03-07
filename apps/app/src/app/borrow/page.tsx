import { Overview } from "@/components/overview";
import {
    Table,
    TableBody,
    TableHead,
    TableHeader,
    TableRow,
} from "@/components/ui/table";
import { BorrowCard } from "@/components/borrow-card";
import { BorrowedCard } from "@/components/borrowed-card";
import { assets } from "@/shared/metadata";

export default function BorrowPage() {
    const borrowedCards = assets.map((asset) => (
        <BorrowedCard
            key={asset.address}
            symbol={asset.symbol}
            icon={asset.icon}
            debtTokenAddress={asset.debtTokenAddress}
            poolAddress={asset.poolAddress}
        />
    ));

    return (
        <div className="space-y-8">
            <Overview />

            <div className="space-y-4">
                <h1 className="font-bold text-2xl">Borrow</h1>

                <div className="grid grid-cols-2 gap-4">
                    <div className="space-y-4 border rounded-lg p-4">
                        <h2 className="font-semibold text-lg">
                            Assets to Borrow
                        </h2>

                        <Table>
                            <TableHeader>
                                <TableRow>
                                    <TableHead>Asset</TableHead>
                                    <TableHead>You Can Borrow</TableHead>
                                    <TableHead>Interest</TableHead>
                                    <TableHead className="text-right">
                                        Action
                                    </TableHead>
                                </TableRow>
                            </TableHeader>

                            <TableBody>
                                {assets.map((asset) => (
                                    <BorrowCard
                                        key={asset.symbol}
                                        symbol={asset.symbol}
                                        icon={asset.icon}
                                        tokenAddress={asset.address}
                                        poolAddress={asset.poolAddress}
                                    />
                                ))}
                            </TableBody>
                        </Table>
                    </div>

                    <div className="space-y-4 border rounded-lg p-4">
                        <h2 className="font-semibold text-lg">
                            Assets Borrowed
                        </h2>

                        {borrowedCards.length > 0 ? (
                            <Table>
                                <TableHeader>
                                    <TableRow>
                                        <TableHead>Asset</TableHead>
                                        <TableHead>Borrowed</TableHead>
                                        <TableHead>Interest</TableHead>
                                        <TableHead className="text-right">
                                            Action
                                        </TableHead>
                                    </TableRow>
                                </TableHeader>

                                <TableBody>{borrowedCards}</TableBody>
                            </Table>
                        ) : (
                            <p className="text-muted-foreground">
                                You haven't borrowed anything yet
                            </p>
                        )}
                    </div>
                </div>
            </div>
        </div>
    );
}
