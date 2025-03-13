import { ImageResponse } from "next/og";

export const runtime = "edge";

export async function GET() {
  try {
    return new ImageResponse(<div>deSync</div>);
  } catch (e: any) {
    return new Response("Failed to generate OG image", { status: 500 });
  }
}
