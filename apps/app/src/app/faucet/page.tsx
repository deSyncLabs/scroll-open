import { FaucetCard } from "@/components/faucet-card";
import { assets } from "@/shared/metadata";

export default function FaucetPage() {
    return (
        <div className="space-y-4">
            <h1 className="font-bold text-2xl">Faucet</h1>

            <div className="border rounded-lg p-4 grid grid-cols-1 md:grid-cols-3 gap-4">
                {assets.map((asset) => (
                    <FaucetCard
                        key={asset.address}
                        symbol={asset.symbol}
                        icon={asset.icon}
                        address={asset.address}
                    />
                ))}
            </div>
        </div>
    );
}
