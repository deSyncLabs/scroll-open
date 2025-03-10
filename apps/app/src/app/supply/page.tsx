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

export default function SupplyPage() {
    const apys: { [key: string]: bigint } = {
        BTC: BigInt(17886) * BigInt(10 ** 22),
        ETH: BigInt(25276) * BigInt(10 ** 22),
        USDC: BigInt(983) * BigInt(10 ** 23),
    };

    const suppliedCards = assets.map((asset) => (
        <SuppliedCard
            key={asset.address}
            symbol={asset.symbol}
            icon={asset.icon}
            deTokenAddress={asset.deTokenAddress}
            poolAddress={asset.poolAddress}
            testAPY={apys[asset.symbol]}
        />
    ));

    return (
        <div className="space-y-8">
            <Overview />

            <div className="space-y-4">
                <h1 className="font-bold text-2xl">Supply</h1>

                <div className="grid grid-cols-1 lg:grid-cols-2 gap-4">
                    <div className="order-2 lg:order-1 space-y-4 border rounded-lg p-4">
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
                                        testAPY={apys[asset.symbol]}
                                    />
                                ))}
                            </TableBody>
                        </Table>
                    </div>

                    <div className="order-1 lg:order-2 space-y-4 border rounded-lg p-4">
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
                                {"You haven't supplied anything yet"}
                            </p>
                        )}
                    </div>
                </div>
            </div>
        </div>
    );
}
