import { DollarSign, HandCoins, Heart } from "lucide-react";

export function Overview() {
    return (
        <div className="border rounded-lg grid grid-cols-3 divide-x">
            <div className="p-4 flex justify-between items-center">
                <div>
                    <p className="text-muted-foreground text-lg">Collateral</p>
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

        {/* TODO: Add "i" button */}
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
    );
}
