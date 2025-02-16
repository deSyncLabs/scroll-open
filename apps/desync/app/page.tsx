"use client"

import { Navigation } from "@/components/navigation"
import { MetricsCards } from "@/components/metrics-cards"
import { SupplySection } from "@/components/supply-section"
import { BorrowSection } from "@/components/borrow-section"

export default function Home() {
  return (
    <div className="min-h-screen bg-[#0A0A0A] text-white">
      <Navigation />
      <main className="container mx-auto px-4 py-8">
        <h1 className="text-3xl font-bold mb-8">Borrow</h1>
        <MetricsCards />
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 mt-6">
          <SupplySection />
          <BorrowSection />
        </div>
      </main>
    </div>
  )
}