"use client";

import { Card } from "@/components/ui/card";
import { DollarSign, Percent, Shield } from "lucide-react";

export function MetricsCards() {
  return (
    <div className="grid gap-4 md:grid-cols-3">
      <Card className="p-6 border-border">
        <div className="flex items-center justify-between">
          <div>
            <p className="text-sm text-gray-400">Your net worth</p>
            <h2 className="text-2xl font-bold mt-1">$10,022.44</h2>
          </div>
          <div className="p-2 rounded-lg">
            <DollarSign className="h-5 w-5 text-orange-500" />
          </div>
        </div>
      </Card>

      <Card className="p-6 border-border">
        <div className="flex items-center justify-between">
          <div>
            <p className="text-sm text-gray-400">Net APY</p>
            <h2 className="text-2xl font-bold mt-1">2.4%</h2>
          </div>
          <div className="p-2 rounded-lg">
            <Percent className="h-5 w-5 text-orange-500" />
          </div>
        </div>
      </Card>

      <Card className="p-6 border-border">
        <div className="flex items-center justify-between">
          <div>
            <p className="text-sm text-gray-400">Health Factor</p>
            <h2 className="text-2xl font-bold mt-1">1.5</h2>
          </div>
          <div className="p-2 rounded-lg">
            <Shield className="h-5 w-5 text-orange-500" />
          </div>
        </div>
      </Card>
    </div>
  );
}
