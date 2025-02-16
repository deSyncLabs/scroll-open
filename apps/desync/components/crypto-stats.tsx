"use client"

import { Card } from "@/components/ui/card"
import { ArrowUpRight, ArrowDownRight, Percent } from "lucide-react"

export function CryptoStats() {
  return (
    <div className="grid gap-4 md:grid-cols-3">
      <Card className="p-6">
        <div className="flex items-center justify-between">
          <div>
            <p className="text-sm text-muted-foreground">Total Portfolio Value</p>
            <h2 className="text-3xl font-bold">$24,532.21</h2>
          </div>
          <div className="flex items-center text-green-500">
            <ArrowUpRight className="h-4 w-4 mr-1" />
            <span>2.5%</span>
          </div>
        </div>
      </Card>
      <Card className="p-6">
        <div className="flex items-center justify-between">
          <div>
            <p className="text-sm text-muted-foreground">24h Volume</p>
            <h2 className="text-3xl font-bold">$1.2M</h2>
          </div>
          <div className="flex items-center text-red-500">
            <ArrowDownRight className="h-4 w-4 mr-1" />
            <span>1.2%</span>
          </div>
        </div>
      </Card>
      <Card className="p-6">
        <div className="flex items-center justify-between">
          <div>
            <p className="text-sm text-muted-foreground">Total Assets</p>
            <h2 className="text-3xl font-bold">3</h2>
          </div>
          <Percent className="h-6 w-6 text-muted-foreground" />
        </div>
      </Card>
    </div>
  )
}