"use client"

import { Card } from "@/components/ui/card"
import { Button } from "@/components/ui/button"

export function BorrowSection() {
  return (
    <Card className="bg-[#111] border-gray-800 p-6">
      <div className="flex justify-between items-center mb-6">
        <div>
          <h2 className="text-lg font-semibold">Borrow ARTH</h2>
          <p className="text-sm text-gray-400">Total Borrowed: $0.01</p>
        </div>
        <p className="text-sm text-gray-400">APY 12.53%</p>
      </div>

      <div className="flex flex-col items-center justify-center space-y-6 py-8">
        <div className="relative w-48 h-48">
          <div className="absolute inset-0 flex items-center justify-center">
            <div className="text-center">
              <p className="text-2xl font-bold text-green-500">70.3%</p>
              <p className="text-sm text-gray-400">Borrow power used</p>
            </div>
          </div>
        </div>

        <div className="w-full space-y-4">
          <div className="flex justify-between">
            <div>
              <p className="text-sm text-gray-400">1.57% APY</p>
              <p className="text-xs text-gray-500">Variable</p>
            </div>
            <div className="text-right">
              <p className="font-semibold">$99.2K</p>
              <Button variant="outline" size="sm" className="mt-1 bg-[#222] hover:bg-[#333] border-gray-700">
                Repay
              </Button>
            </div>
          </div>

          <div className="flex justify-between">
            <div>
              <p className="text-sm text-gray-400">5.33% APY</p>
              <p className="text-xs text-gray-500">Stable APY</p>
            </div>
            <div className="text-right">
              <p className="font-semibold">$222.9K</p>
              <Button variant="outline" size="sm" className="mt-1 bg-[#222] hover:bg-[#333] border-gray-700">
                Repay
              </Button>
            </div>
          </div>
        </div>

        <Button className="w-full bg-orange-500 hover:bg-orange-600">
          Borrow
        </Button>
      </div>
    </Card>
  )
}