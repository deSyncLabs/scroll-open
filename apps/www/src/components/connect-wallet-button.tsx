import { ConnectKitButton } from "connectkit";
import { LoaderCircle } from "lucide-react";
import { cn } from "@/lib/utils";
import { Button } from "./ui/button";

export function ConnectWalletButton({ className }: { className?: string }) {
    return (
        <ConnectKitButton.Custom>
            {({ isConnected, isConnecting, show, truncatedAddress }) => (
                <Button
                    onClick={show}
                    className={cn("hover:cursor-pointer", className)}
                    disabled={isConnecting}
                    variant={isConnected ? "secondary" : "default"}
                >
                    {isConnected ? (
                        truncatedAddress
                    ) : isConnecting ? (
                        <LoaderCircle className="animate-spin" />
                    ) : (
                        "Connect Wallet"
                    )}
                </Button>
            )}
        </ConnectKitButton.Custom>
    );
}
