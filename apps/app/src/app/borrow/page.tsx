import { Overview } from "@/components/overview";
import {
    Table,
    TableBody,
    TableCell,
    TableHead,
    TableHeader,
    TableRow,
} from "@/components/ui/table";
import { Button } from "@/components/ui/button";
import { assets } from "@/shared/assets";

export default function BorrowPage() {
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
                                    <TableHead>Wallet Balance</TableHead>
                                    <TableHead>APY</TableHead>
                                    <TableHead className="text-right">
                                        Action
                                    </TableHead>
                                </TableRow>
                            </TableHeader>

                            <TableBody>
                                {assets.map((asset) => (
                                    <TableRow key={asset.symbol}>
                                        <TableCell>
                                            <div className="flex items-center space-x-3">
                                                <img
                                                    src={asset.icon}
                                                    alt={asset.symbol}
                                                    className="rounded-full w-6 h-6"
                                                />
                                                <span>{asset.symbol}</span>
                                            </div>
                                        </TableCell>
                                        <TableCell className="text-center">
                                            {0}
                                        </TableCell>
                                        <TableCell className="text-center">
                                            {asset.apy}%
                                        </TableCell>
                                        <TableCell className="text-right">
                                            <Button>Borrow</Button>
                                        </TableCell>
                                    </TableRow>
                                ))}
                            </TableBody>
                        </Table>
                    </div>

                    <div className="space-y-4 border rounded-lg p-4">
                        <h2 className="font-semibold text-lg">
                            Assets Borrowed
                        </h2>

                        <div>
                            <p className="text-muted-foreground">
                                You haven't borrowed anything yet
                            </p>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    );
}
