"use client"

import { Card } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import Image from "next/image"
import { Switch } from "@/components/ui/switch"
import { Check } from "lucide-react"

export function SupplySection() {
  return (
    <Card className="bg-[#111] border-gray-800 p-6">
      <div className="flex justify-between items-center mb-6">
        <div>
          <h2 className="text-lg font-semibold">Your Supplies</h2>
          <p className="text-sm text-gray-400">Total Supply: $0.01</p>
        </div>
        <p className="text-sm text-gray-400">APY 12.53%</p>
      </div>

      <div className="space-y-4">
        {/* Column Headers */}
        <div className="grid grid-cols-[2fr_2fr_0.75fr_4fr] gap-4 px-4 text-sm text-gray-400">
          <div>Asset</div>
          <div>Wallet Balance</div>
          <div>APY</div>
          <div>Collateral</div>
        </div>

        {/* Supply Item */}
        <div className="flex items-center justify-between p-4 bg-[#0A0A0A] rounded-lg">
          <div className="grid grid-cols-[2fr_2fr_0.75fr_4fr] gap-4 w-full items-center">
            <div className="flex items-center space-x-3">
              <Image
                src="https://assets.coingecko.com/coins/images/6319/small/USD_Coin_icon.png"
                width={24}
                height={24}
                alt="USDC"
                className="rounded-full"
              />
              <span>USDC</span>
            </div>
            <div>0.4599447</div>
            <div>2.53%</div>
            <div className="flex items-center gap-2">
              <Switch className="shrink-0" />
              <Button size="sm" variant="outline" className="bg-[#222] hover:bg-[#333] border-gray-700">
                Withdraw
              </Button>
              <Button size="sm" variant="outline" className="bg-[#222] hover:bg-[#333] border-gray-700">
                Supply
              </Button>
            </div>
          </div>
        </div>
      </div>

      {/* Assets to Supply Section */}
      <div className="mt-8">
        <h2 className="text-lg font-semibold mb-6">Assets to Supply</h2>
        <div className="space-y-4">
          {/* Column Headers */}
          <div className="grid grid-cols-[2fr_2fr_0.75fr_4fr] gap-4 px-4 text-sm text-gray-400">
            <div>Asset</div>
            <div>Wallet Balance</div>
            <div>APY</div>
            <div>Collateral</div>
          </div>

          {/* Asset Items */}
          {[
            { symbol: "USDC", image: "https://assets.coingecko.com/coins/images/6319/small/USD_Coin_icon.png" },
            { symbol: "ETH", image: "https://assets.coingecko.com/coins/images/279/small/ethereum.png" },
            { symbol: "BTC", image: "https://assets.coingecko.com/coins/images/1/small/bitcoin.png" }
          ].map((asset) => (
            <div key={asset.symbol} className="flex items-center justify-between p-4 bg-[#0A0A0A] rounded-lg">
              <div className="grid grid-cols-[2fr_2fr_0.75fr_4fr] gap-4 w-full items-center">
                <div className="flex items-center space-x-3">
                  <Image
                    src={asset.image}
                    width={24}
                    height={24}
                    alt={asset.symbol}
                    className="rounded-full"
                  />
                  <span>{asset.symbol}</span>
                </div>
                <div>0.4599447</div>
                <div>2.53%</div>
                <div className="flex items-center gap-2">
                  <div className="w-5 h-5 flex items-center justify-center">
                    <Check className="h-4 w-4 text-green-500" />
                  </div>
                  <div className="flex justify-end gap-2">
                    <Button size="sm" variant="outline" className="bg-[#222] hover:bg-[#333] border-gray-700">
                    Supply
                  </Button>
                  <Button size="sm" variant="outline" className="bg-[#222] hover:bg-[#333] border-gray-700">
                    Leverage
                  </Button></div>
                </div>
                
              </div>
            </div>
          ))}
        </div>
      </div>
    </Card>
  )
}