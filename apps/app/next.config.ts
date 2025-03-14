import type { NextConfig } from "next";

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

export default nextConfig;
