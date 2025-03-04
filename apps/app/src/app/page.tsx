import { DollarSign, HandCoins, Heart } from "lucide-react";
import {
    Table,
    TableBody,
    TableCell,
    TableHead,
    TableHeader,
    TableRow,
} from "@/components/ui/table";
import { Button } from "@/components/ui/button";

export default function Home() {
    const assets = [
        {
            symbol: "BTC",
            icon: "https://assets.coingecko.com/coins/images/1/small/bitcoin.png",
            address: "0xB",
            apy: 10.0,
        },
        {
            symbol: "ETH",
            icon: "https://assets.coingecko.com/coins/images/279/small/ethereum.png",
            address: "0xE",
            apy: 5.0,
        },
        {
            symbol: "USDC",
            icon: "https://assets.coingecko.com/coins/images/6319/small/USD_Coin_icon.png",
            address: "0xC",
            apy: 2.0,
        },
    ];

    const supplied = [
        {
            address: "0xB",
            supplied: 12.34,
        },
        {
            address: "0xE",
            supplied: 56.78,
        },
    ];

    return (
        <div className="space-y-4">
            <div className="border rounded-lg grid grid-cols-3 divide-x">
                <div className="p-4 flex justify-between items-center">
                    <div>
                        <p className="text-muted-foreground text-lg">
                            Collateral
                        </p>
                        <p className="text-2xl">$0.00</p>
                    </div>

                    <div className="bg-muted p-2 rounded-lg">
                        <DollarSign />
                    </div>
                </div>

                <div className="p-4 flex justify-between items-center">
                    <div>
                        <p className="text-muted-foreground text-lg">
                            Borrowed Amount
                        </p>
                        <p className="text-2xl">$0.00</p>
                    </div>

                    <div className="bg-muted p-2 rounded-lg">
                        <HandCoins />
                    </div>
                </div>

                <div className="p-4 flex justify-between items-center">
                    <div>
                        <p className="text-muted-foreground text-lg">
                            Health Factor
                        </p>
                        <p className="text-2xl">0.00</p>
                    </div>

                    <div className="bg-muted p-2 rounded-lg">
                        <Heart />
                    </div>
                </div>
            </div>

            <div className="grid grid-cols-2 gap-4">
                <div className="border rounded-lg p-4 space-y-8">
                    <h2 className="font-bold text-2xl">Supply</h2>

                    <div className="space-y-4">
                        <h3 className="font-semibold text-lg">Your Supplies</h3>
                        <div>
                            {supplied.length > 0 ? (
                                <Table className="w-full">
                                    <TableHeader>
                                        <TableRow>
                                            <TableHead>Asset</TableHead>
                                            <TableHead>Supplied</TableHead>
                                            <TableHead>APY</TableHead>
                                            <TableHead className="text-right">
                                                Actions
                                            </TableHead>
                                        </TableRow>
                                    </TableHeader>

                                    <TableBody>
                                        {supplied.map((supply) => (
                                            <TableRow key={supply.address}>
                                                <TableCell className="flex items-center space-x-3 py-4">
                                                    <img
                                                        src={
                                                            assets.find(
                                                                (asset) =>
                                                                    asset.address ===
                                                                    supply.address
                                                            )!.icon
                                                        }
                                                        alt={supply.address}
                                                        className="rounded-full w-6 h-6"
                                                    />
                                                    <span>
                                                        {
                                                            assets.find(
                                                                (asset) =>
                                                                    asset.address ===
                                                                    supply.address
                                                            )!.symbol
                                                        }
                                                    </span>
                                                </TableCell>
                                                <TableCell>
                                                    {supply.supplied}
                                                </TableCell>
                                                <TableCell>
                                                    {
                                                        assets.find(
                                                            (asset) =>
                                                                asset.address ===
                                                                supply.address
                                                        )!.apy
                                                    }
                                                    %
                                                </TableCell>
                                                <TableCell>
                                                    <div className="flex justify-end">
                                                        <Button>
                                                            Withdraw
                                                        </Button>
                                                    </div>
                                                </TableCell>
                                            </TableRow>
                                        ))}
                                    </TableBody>
                                </Table>
                            ) : (
                                <p className="text-muted-foreground">
                                    No assets supplied yet!
                                </p>
                            )}
                        </div>
                    </div>

                    <div className="space-y-4">
                        <h3 className="font-semibold text-lg">
                            Assets to Supply
                        </h3>
                        <div>
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
                                            <TableCell className="flex items-center space-x-3 py-4">
                                                <img
                                                    src={asset.icon}
                                                    alt={asset.symbol}
                                                    className="rounded-full w-6 h-6"
                                                />
                                                <span>{asset.symbol}</span>
                                            </TableCell>
                                            <TableCell>0.00</TableCell>
                                            <TableCell>0.00%</TableCell>
                                            <TableCell>
                                                <div className="flex justify-end">
                                                    <Button>Supply</Button>
                                                </div>
                                            </TableCell>
                                        </TableRow>
                                    ))}
                                </TableBody>
                            </Table>
                        </div>
                    </div>
                </div>

                <div className="border rounded-lg p-4 space-y-8">
                    <h2 className="font-bold text-2xl">Borrow</h2>

                    <div className="space-y-4">
                        <h3 className="font-semibold text-lg">Your Borrows</h3>
                        <div>
                            <p className="text-muted-foreground">
                                No assets borrowed yet!
                            </p>
                        </div>
                    </div>

                    <div className="space-y-4">
                        <h3 className="font-semibold text-lg">
                            Assets to Borrow
                        </h3>
                        <div>
                            <Table>
                                <TableHeader>
                                    <TableRow>
                                        <TableHead>Asset</TableHead>
                                        <TableHead>Available</TableHead>
                                        <TableHead>Interest</TableHead>
                                        <TableHead className="text-right">
                                            Actions
                                        </TableHead>
                                    </TableRow>
                                </TableHeader>

                                <TableBody>
                                    {assets.map((asset) => (
                                        <TableRow key={asset.symbol}>
                                            <TableCell className="flex items-center space-x-3 py-4">
                                                <img
                                                    src={asset.icon}
                                                    alt={asset.symbol}
                                                    className="rounded-full w-6 h-6"
                                                />
                                                <span>{asset.symbol}</span>
                                            </TableCell>
                                            <TableCell>0.00</TableCell>
                                            <TableCell>0.00%</TableCell>
                                            <TableCell>
                                                <div className="flex justify-end">
                                                    <Button>Borrow</Button>
                                                </div>
                                            </TableCell>
                                        </TableRow>
                                    ))}
                                </TableBody>
                            </Table>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    );
}
