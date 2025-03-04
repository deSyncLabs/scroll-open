import { Button } from "@/components/ui/button";
import { assets } from "@/shared/assets";

export default function FaucetPage() {
    return (
        <div className="space-y-4">
            <h1 className="font-bold text-2xl">Faucet</h1>

            <div className="border rounded-lg p-4 grid grid-cols-3 gap-4">
                {assets.map((asset) => (
                    <div
                        key={asset.symbol}
                        className="border rounded-sm p-4 flex flex-col items-center space-y-4"
                    >
                        <div>
                            <picture>
                                <img src={asset.icon} alt="" />
                            </picture>
                        </div>

                        <div>
                            <h2 className="font-semibold text-lg">
                                {asset.symbol}
                            </h2>
                        </div>

                        <div>
                            <Button>Mint</Button>
                        </div>
                    </div>
                ))}
            </div>
        </div>
    );
}
