"use client";

import Link from "next/link";
import { Github } from "lucide-react";
import { Button } from "./ui/button";

export function Navbar() {
    return (
        <header className="absolute left-0 top-0 z-[100] flex w-full flex-col px-5 py-2 sm:py-0">
            <nav className="flex h-[48px] bg-background justify-center">
                <div className="container flex flex-col sm:flex-row items-center justify-between w-full">
                    <div className="flex justify-between w-full">
                        <Link href="/" className="font-bold text-3xl">
                            deSync
                        </Link>

                        <ul className="flex space-x-2 items-center">
                            <li>
                                <Button variant={"ghost"} asChild>
                                    <a
                                        href="https://github.com/deSyncLabs/scroll-open/"
                                        target="_blank"
                                        rel="noopener noreferrer"
                                    >
                                        <Github size={16} />
                                    </a>
                                </Button>
                            </li>

                            <li>
                                <Button disabled variant={"ghost"} asChild>
                                    <a
                                        href="https://docs.desync.fi/"
                                        target="_blank"
                                        rel="noopener noreferrer"
                                    >
                                        Docs
                                    </a>
                                </Button>
                            </li>

                            <li>
                                <Button asChild>
                                    <a
                                        href="https://testnet.desync.fi"
                                        target="_blank"
                                        rel="noopener noreferrer"
                                    >
                                        Testnet
                                    </a>
                                </Button>
                            </li>
                        </ul>
                    </div>
                </div>
            </nav>
        </header>
    );
}
