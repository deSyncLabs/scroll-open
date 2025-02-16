"use client"

import Link from "next/link"
import { Button } from "@/components/ui/button"
import { Flame } from "lucide-react"

export function Navigation() {
  return (
    <nav className="border-b border-gray-800">
      <div className="container mx-auto px-4 h-16 flex items-center justify-between">
        <div className="flex items-center space-x-12">
          <div className="flex items-center space-x-2">
            <Flame className="h-6 w-6 text-orange-500" />
            <span className="font-bold text-lg">DeSync</span>
          </div>
          <div className="flex items-center space-x-8">
            <Link href="/" className="text-orange-500">Dashboard</Link>
            <Link href="/earn" className="text-gray-400 hover:text-white">Earn</Link>
            <Link href="/market" className="text-gray-400 hover:text-white">Market</Link>
          </div>
        </div>
        <Button className="bg-[#222] hover:bg-[#333] text-white px-6">
          0xA9a...90190
        </Button>
      </div>
    </nav>
  )
}