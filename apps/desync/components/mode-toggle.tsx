"use client";

import * as React from "react";
import { Moon, Sun, Monitor } from "lucide-react";
import { useTheme } from "next-themes";

import { Button } from "@/components/ui/button";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";

export function ModeToggle() {
  const { setTheme } = useTheme();

  return (
    <>
      <Button
        variant="outline"
        size="icon"
        onClick={() => setTheme("dark")}
        title={"Dark Mode"}
      >
        <Moon className="h-[1.2rem] w-[1.2rem]" />
      </Button>
      <Button
        variant="outline"
        size="icon"
        onClick={() => setTheme("light")}
        title={"Light Mode"}
      >
        <Sun className="h-[1.2rem] w-[1.2rem]" />
      </Button>
      <Button
        variant="outline"
        size="icon"
        onClick={() => setTheme("system")}
        title={"System Mode"}
      >
        <Monitor className="h-[1.2rem] w-[1.2rem]" />
      </Button>
    </>
  );
}
