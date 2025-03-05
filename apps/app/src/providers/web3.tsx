"use client";

import { WagmiProvider, createConfig, http } from "wagmi";
import { scrollSepolia } from "wagmi/chains";
import { getDefaultConfig, ConnectKitProvider } from "connectkit";

const config = createConfig(
    getDefaultConfig({
        chains: [scrollSepolia],
        transports: {
            [scrollSepolia.id]: http(
                process.env.NEXT_PUBLIC_SCROLL_SEPOLIA_RPC_URL!
            ),
        },
        walletConnectProjectId:
            process.env.NEXT_PUBLIC_WALLETCONNECT_PROJECT_ID!,
        appName: "deSync",
        appDescription: "Zero Interest Lending Protocol",
        appUrl: "https://family.co",
        appIcon: "https://family.co/logo.png",
    })
);

export function Web3Provider({ children }: { children: React.ReactNode }) {
    return (
        <WagmiProvider config={config}>
            <ConnectKitProvider>{children}</ConnectKitProvider>
        </WagmiProvider>
    );
}
