"use client";

import Link from "next/link";
import { Button } from "@/components/ui/button";
import { Flame } from "lucide-react";
import { ModeToggle } from "./mode-toggle";

export function Navigation() {
  return (
    <nav className="border-border">
      <div className="container mx-auto px-4 h-16 flex items-center justify-between">
        <div className="flex items-center space-x-12">
          <div className="flex items-center space-x-2">
            <Flame className="h-6 w-6 text-orange-500" />
            <span className="font-bold text-lg">DeSync</span>
          </div>
          <div className="flex items-center space-x-8">
            {/*<Link href="/" className="text-orange-500">
              Dashboard
            </Link>
            <Link href="/earn" className="">
              Earn
            </Link>
            <Link href="/market" className="">
              Market
            </Link>*/}
            <ModeToggle />
          </div>
        </div>
        <Button className="" variant={"secondary"}>
          0xA9a...90190
        </Button>
      </div>
    </nav>
  );
}
