"use client";

import * as React from "react";
import { Moon, Sun, Monitor } from "lucide-react";
import { useTheme } from "next-themes";
import { useState } from "react";

import { Button } from "@/components/ui/button";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";

export function ModeToggle() {
  const { setTheme } = useTheme();
  const [iconButton, setIconButton] = useState("system");

  return (
    <>
      {iconButton == "dark" && (
        <Button
          variant="outline"
          size="icon"
          onClick={() => {
            setTheme("dark");
            setIconButton("light");
          }}
          title={"Dark Mode"}
        >
          <Moon className="h-[1.2rem] w-[1.2rem]" />
        </Button>
      )}
      {iconButton == "light" && (
        <Button
          variant="outline"
          size="icon"
          onClick={() => {
            setTheme("light");
            setIconButton("system");
          }}
          title={"Light Mode"}
        >
          <Sun className="h-[1.2rem] w-[1.2rem]" />
        </Button>
      )}
      {iconButton == "system" && (
        <Button
          variant="outline"
          size="icon"
          onClick={() => {
            setTheme("system");
            setIconButton("dark");
          }}
          title={"System Mode"}
        >
          <Monitor className="h-[1.2rem] w-[1.2rem]" />
        </Button>
      )}
    </>
  );
}
