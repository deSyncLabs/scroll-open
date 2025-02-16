"use client"

import { Card } from "@/components/ui/card"
import Image from "next/image"

const tokens = [
  {
    name: "Bitcoin",
    symbol: "BTC",
    price: 43521.23,
    change: 2.5,
    image: "https://assets.coingecko.com/coins/images/1/small/bitcoin.png",
  },
  {
    name: "Ethereum",
    symbol: "ETH",
    price: 2235.12,
    change: -1.2,
    image: "https://assets.coingecko.com/coins/images/279/small/ethereum.png",
  },
  {
    name: "USD Coin",
    symbol: "USDC",
    price: 1.00,
    change: 0.01,
    image: "https://assets.coingecko.com/coins/images/6319/small/USD_Coin_icon.png",
  },
]

export function TokenList() {
  return (
    <Card className="p-6">
      <h3 className="font-semibold mb-4">Token Prices</h3>
      <div className="space-y-4">
        {tokens.map((token) => (
          <div key={token.symbol} className="flex items-center justify-between">
            <div className="flex items-center space-x-3">
              <Image
                src={token.image}
                alt={token.name}
                width={32}
                height={32}
                className="rounded-full"
              />
              <div>
                <p className="font-medium">{token.name}</p>
                <p className="text-sm text-muted-foreground">{token.symbol}</p>
              </div>
            </div>
            <div className="text-right">
              <p className="font-medium">${token.price.toLocaleString()}</p>
              <p className={`text-sm ${token.change >= 0 ? "text-green-500" : "text-red-500"}`}>
                {token.change >= 0 ? "+" : ""}{token.change}%
              </p>
            </div>
          </div>
        ))}
      </div>
    </Card>
  )
}