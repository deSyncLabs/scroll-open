import { Overview } from "@/components/overview";
import {
    Table,
    TableBody,
    TableHead,
    TableHeader,
    TableRow,
} from "@/components/ui/table";
import { SupplyCard } from "@/components/supply-card";
import { assets } from "@/shared/metadata";
import { SuppliedCard } from "@/components/supplied-card";

// TODO: Refetch everything when the user deposits or withdraws

export default function SupplyPage() {
    const suppliedCards = assets.map((asset) => (
        <SuppliedCard
            key={asset.address}
            symbol={asset.symbol}
            icon={asset.icon}
            deTokenAddress={asset.deTokenAddress}
            poolAddress={asset.poolAddress}
        />
    ));

    return (
        <div className="space-y-8">
            <Overview />

            <div className="space-y-4">
                <h1 className="font-bold text-2xl">Supply</h1>

                <div className="grid grid-cols-2 gap-4">
                    <div className="space-y-4 border rounded-lg p-4">
                        <h2 className="font-semibold text-lg">
                            Assets to Supply
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
                                    <SupplyCard
                                        key={asset.address}
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
                            Assets Supplied
                        </h2>

                        {suppliedCards.length > 0 ? (
                            <Table>
                                <TableHeader>
                                    <TableRow>
                                        <TableHead>Asset</TableHead>
                                        <TableHead>Supplied</TableHead>
                                        <TableHead>APY</TableHead>
                                        <TableHead className="text-right">
                                            Action
                                        </TableHead>
                                    </TableRow>
                                </TableHeader>

                                <TableBody>{suppliedCards}</TableBody>
                            </Table>
                        ) : (
                            <p className="text-muted-foreground">
                                You haven't supplied anything yet
                            </p>
                        )}
                    </div>
                </div>
            </div>
        </div>
    );
}
