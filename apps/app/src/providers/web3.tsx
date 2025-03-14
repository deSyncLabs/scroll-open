"use client";

import { WagmiProvider, createConfig, http } from "wagmi";
import { scrollSepolia } from "wagmi/chains";
import { getDefaultConfig, ConnectKitProvider } from "connectkit";

const config = createConfig(
    getDefaultConfig({
        chains: [scrollSepolia],
        transports: {
            [scrollSepolia.id]: http("/rpc/scroll-sepolia"),
        },
        walletConnectProjectId:
            process.env.NEXT_PUBLIC_WALLETCONNECT_PROJECT_ID!,
        appName: "deSync",
        appDescription: "Zero Interest Lending Protocol",
        appUrl: "https://testnet.desync.fi",
        appIcon: "/logo.png",
    })
);

export function Web3Provider({ children }: { children: React.ReactNode }) {
    return (
        <WagmiProvider config={config}>
            <ConnectKitProvider>{children}</ConnectKitProvider>
        </WagmiProvider>
    );
}
