"use client";

// import { Button } from "@/components/ui/button";
import { motion } from "framer-motion";
import { LampDemo } from "@/components/ui/lamp";
import { Navbar } from "@/components/navbar";
// import { ArrowRight, Shield, Zap, RefreshCw } from "lucide-react";
// import Link from "next/link";
{
  /* 
export default function Home() {
  return (
    <div className="min-h-screen bg-[#0A0A0A]">

      <section className="relative">
        <div className="absolute inset-0 bg-gradient-to-br from-orange-500/20 to-purple-500/20 pointer-events-none" />
        <div className="container mx-auto px-4 py-24 relative">
          <div className="max-w-3xl">
            <h1 className="text-5xl md:text-6xl font-bold text-white mb-6">
              Your Gateway to{" "}
              <span className="text-orange-500">Decentralized Finance</span>
            </h1>
            <p className="text-xl text-gray-300 mb-8">
              Earn, borrow, and grow your wealth with DeSync. Simple, secure,
              and accessible to everyone.
            </p>
            <div className="flex gap-4">
              <Link href="/dashboard">
                <Button size="lg" className="bg-orange-500 hover:bg-orange-600">
                  Get Started <ArrowRight className="ml-2 h-5 w-5" />
                </Button>
              </Link>
              <Button
                size="lg"
                variant="outline"
                className="border-gray-700 hover:bg-gray-800"
              >
                Learn More
              </Button>
            </div>
          </div>
        </div>
      </section>

      <section className="py-20 bg-[#111]">
        <div className="container mx-auto px-4">
          <h2 className="text-3xl font-bold text-white text-center mb-12">
            Why Choose DeSync?
          </h2>
          <div className="grid md:grid-cols-3 gap-8">
            <div className="bg-[#1A1A1A] p-8 rounded-xl border border-gray-800">
              <div className="bg-orange-500/10 w-12 h-12 rounded-lg flex items-center justify-center mb-6">
                <Shield className="h-6 w-6 text-orange-500" />
              </div>
              <h3 className="text-xl font-semibold text-white mb-4">
                Secure & Reliable
              </h3>
              <p className="text-gray-400">
                Built with industry-leading security standards to keep your
                assets safe and protected.
              </p>
            </div>
            <div className="bg-[#1A1A1A] p-8 rounded-xl border border-gray-800">
              <div className="bg-orange-500/10 w-12 h-12 rounded-lg flex items-center justify-center mb-6">
                <Zap className="h-6 w-6 text-orange-500" />
              </div>
              <h3 className="text-xl font-semibold text-white mb-4">
                Lightning Fast
              </h3>
              <p className="text-gray-400">
                Experience instant transactions and real-time updates on your
                investments.
              </p>
            </div>
            <div className="bg-[#1A1A1A] p-8 rounded-xl border border-gray-800">
              <div className="bg-orange-500/10 w-12 h-12 rounded-lg flex items-center justify-center mb-6">
                <RefreshCw className="h-6 w-6 text-orange-500" />
              </div>
              <h3 className="text-xl font-semibold text-white mb-4">
                Flexible Options
              </h3>
              <p className="text-gray-400">
                Choose from a variety of assets and strategies to match your
                financial goals.
              </p>
            </div>
          </div>
        </div>
      </section>

      <section className="py-20">
        <div className="container mx-auto px-4">
          <div className="bg-gradient-to-r from-orange-500/10 to-purple-500/10 p-12 rounded-2xl border border-gray-800">
            <div className="max-w-2xl mx-auto text-center">
              <h2 className="text-3xl font-bold text-white mb-6">
                Ready to Start Your DeFi Journey?
              </h2>
              <p className="text-gray-300 mb-8">
                Join thousands of users who are already earning and growing
                their wealth with DeSync.
              </p>
              <Link href="/dashboard">
                <Button size="lg" className="bg-orange-500 hover:bg-orange-600">
                  Launch App <ArrowRight className="ml-2 h-5 w-5" />
                </Button>
              </Link>
            </div>
          </div>
        </div>
      </section>
    </div>
  );
}
*/
}

export default function Home() {
  return (
    <>
      <motion.div
        initial={{ opacity: 0, y: -20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.3, duration: 0.8, ease: "easeInOut" }}
      >
        <Navbar />
      </motion.div>
      <LampDemo />
    </>
  );
}
