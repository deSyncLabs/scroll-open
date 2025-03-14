import type { NextConfig } from "next";
import { setupDevPlatform } from "@cloudflare/next-on-pages/next-dev";

const nextConfig: NextConfig = {
    async rewrites() {
        return [
            {
                source: "/rpc/scroll-sepolia",
                destination: process.env.SCROLL_SEPOLIA_RPC_URL!,
            },
        ];
    },
};

if (process.env.NODE_ENV === "development") {
    await setupDevPlatform();
}

export default nextConfig;
