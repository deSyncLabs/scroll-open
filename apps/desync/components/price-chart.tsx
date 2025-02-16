"use client"

import { Card } from "@/components/ui/card"
import { LineChart, Line, XAxis, YAxis, Tooltip, ResponsiveContainer } from "recharts"
import { Button } from "@/components/ui/button"

const data = [
  { date: "2024-01", price: 42000 },
  { date: "2024-02", price: 44000 },
  { date: "2024-03", price: 43000 },
  { date: "2024-04", price: 45000 },
  { date: "2024-05", price: 47000 },
  { date: "2024-06", price: 46000 },
]

const timeframes = ["1H", "24H", "1W", "1M", "1Y"]

export function PriceChart() {
  return (
    <Card className="p-6">
      <div className="flex items-center justify-between mb-6">
        <h3 className="font-semibold">Price Chart</h3>
        <div className="flex space-x-2">
          {timeframes.map((tf) => (
            <Button key={tf} variant="outline" size="sm">
              {tf}
            </Button>
          ))}
        </div>
      </div>
      <div className="h-[400px]">
        <ResponsiveContainer width="100%" height="100%">
          <LineChart data={data}>
            <XAxis dataKey="date" />
            <YAxis />
            <Tooltip />
            <Line
              type="monotone"
              dataKey="price"
              stroke="hsl(var(--primary))"
              strokeWidth={2}
              dot={false}
            />
          </LineChart>
        </ResponsiveContainer>
      </div>
    </Card>
  )
}