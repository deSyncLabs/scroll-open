"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { Button } from "./ui/button";

export function Navbar() {
    const pathname = usePathname();

    return (
        <header className="absolute left-0 top-0 z-[100] flex w-full flex-col px-5 py-2 sm:py-0">
            <nav className="flex h-[48px] bg-background justify-center">
                <div className="container flex flex-col sm:flex-row items-center justify-between w-full">
                    <div className="flex justify-between w-full">
                        <Link href="/" className="font-bold text-3xl">
                            deSync
                        </Link>

                        <ul className="flex space-x-2">
                            <li>
                                <Button disabled variant={"ghost"}>Docs</Button>
                            </li>

                            <li>
                                <Button disabled>Testnet</Button>
                            </li>
                        </ul>
                    </div>
                </div>
            </nav>
        </header>
    );
}
