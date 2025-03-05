"use client";

// SEPARATE EACH ONE INTO ITS OWN COMPNENT

import { FaucetCard } from "@/components/faucet-card";
import { assets } from "@/shared/assets";

type FaucetClientPageProps = {
    assets: typeof assets;
};

export function FaucetClientPage({ assets }: FaucetClientPageProps) {
    // async function handleMint(address: string) {
    //     const hash = await mint.writeContractAsync({
    //         abi: mintableERC20ABI,
    //         address: address as `0x${string}`,
    //         functionName: "mint",
    //     });
    // }

    return (
        <div className="space-y-4">
            <h1 className="font-bold text-2xl">Faucet</h1>

            <div className="border rounded-lg p-4 grid grid-cols-3 gap-4">
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
