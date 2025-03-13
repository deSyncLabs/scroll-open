import type { Metadata } from "next";
import {  Geist_Mono } from "next/font/google";
import { Navbar } from "@/components/navbar";
import { Providers } from "@/providers";
import { cn } from "@/lib/utils";
import "./globals.css";

const geistMono = Geist_Mono({
    variable: "--font-geist-mono",
    subsets: ["latin"],
});

export const metadata: Metadata = {
    title: "deSync - Democratizing loans and yield for all",
    description:
        "Using delta neutral stratergies to offer zero-interest loans while providing the best yield to lenders.",
};

export default function RootLayout({
    children,
}: Readonly<{
    children: React.ReactNode;
}>) {
    return (
        <html lang="en" suppressHydrationWarning>
            <body className={cn(geistMono.variable, "antialiased")}>
                <Providers>
                    <div className="font-[family-name:var(--font-geist-mono)] flex flex-col items-center w-full min-h-svh">
                        <Navbar />
                        <main className="container w-full min-h-svh px-7">
                            {children}
                        </main>
                    </div>
                </Providers>
            </body>
        </html>
    );
}
