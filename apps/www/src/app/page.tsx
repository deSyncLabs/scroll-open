import { Vortex } from "@/components/ui/vortex";
import { Button } from "@/components/ui/button";

export default function HomePage() {
  return (
    <div>
      <Vortex
        className="bg-transparent w-full min-h-svh flex flex-col items-center justify-center"
        backgroundColor="transparent"
        particleCount={1000}
      >
        <div className="max-w-4xl text-center space-y-5 ">
          <h1 className="font-bold text-4xl sm:text-5xl">
            Democratizing loans for all
          </h1>

          <p className="sm:text-xl">
            Using delta neutral strategies to offer zero-interest loans while
            providing the best yield to lenders
          </p>

          <div className="space-y-5 sm:space-x-5 flex flex-col-reverse sm:flex-row justify-center">
            <Button
              variant={"ghost"}
              className="sm:text-lg p-5 hover:bg-accent/70"
              asChild
            >
              <a
                href="https://docs.desync.fi/"
                target="_blank"
                rel="noopener noreferrer"
              >
                Learn More
              </a>
            </Button>

            <Button disabled className="sm:text-lg p-5">
              Testnet
            </Button>
          </div>
        </div>
      </Vortex>
    </div>
  );
}
