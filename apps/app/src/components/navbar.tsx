"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { ConnectWalletButton } from "./connect-wallet-button";
import { Button } from "./ui/button";

export function Navbar() {
    const pathname = usePathname();

    return (
        <header className="sticky left-0 top-0 z-[100] flex w-full flex-col border-b border-border bg-background">
            <nav className="flex sm:h-[48px] bg-background justify-center">
                <div className="container flex flex-col sm:flex-row items-center justify-between w-full">
                    <div className="flex justify-between w-full">
                        <Link href="/" className="font-bold text-3xl">
                            deSync
                        </Link>

                        <ul className="hidden sm:flex space-x-2">
                            <li>
                                <Button
                                    variant="ghost"
                                    asChild
                                    className={
                                        pathname == "/supply"
                                            ? "text-foreground"
                                            : "text-muted-foreground"
                                    }
                                >
                                    <Link href="/supply">Supply</Link>
                                </Button>
                            </li>

                            <li>
                                <Button
                                    variant="ghost"
                                    asChild
                                    className={
                                        pathname == "/borrow"
                                            ? "text-foreground"
                                            : "text-muted-foreground"
                                    }
                                >
                                    <Link href="/borrow">Borrow</Link>
                                </Button>
                            </li>

                            <li>
                                <Button
                                    variant="ghost"
                                    asChild
                                    className={
                                        pathname == "/faucet"
                                            ? "text-foreground"
                                            : "text-muted-foreground"
                                    }
                                >
                                    <Link href="/faucet">Faucet</Link>
                                </Button>
                            </li>
                        </ul>

                        <ConnectWalletButton className="min-w-[150px]" />
                    </div>

                    <div>
                        <ul className="flex sm:hidden space-x-2">
                            <li>
                                <Button
                                    variant="ghost"
                                    asChild
                                    className={
                                        pathname == "/supply"
                                            ? "text-foreground"
                                            : "text-muted-foreground"
                                    }
                                >
                                    <Link href="/supply">Supply</Link>
                                </Button>
                            </li>

                            <li>
                                <Button
                                    variant="ghost"
                                    asChild
                                    className={
                                        pathname == "/borrow"
                                            ? "text-foreground"
                                            : "text-muted-foreground"
                                    }
                                >
                                    <Link href="/borrow">Borrow</Link>
                                </Button>
                            </li>

                            <li>
                                <Button
                                    variant="ghost"
                                    asChild
                                    className={
                                        pathname == "/faucet"
                                            ? "text-foreground"
                                            : "text-muted-foreground"
                                    }
                                >
                                    <Link href="/faucet">Faucet</Link>
                                </Button>
                            </li>
                        </ul>
                    </div>
                </div>
            </nav>
        </header>
    );
}
