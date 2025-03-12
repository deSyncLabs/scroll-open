import { createPublicClient, createWalletClient, http, getAddress } from 'viem';
import { scrollSepolia } from 'viem/chains';
import { privateKeyToAccount } from 'viem/accounts';
import { controllerABI, poolABI } from './abis';

export default {
	async scheduled(_: ScheduledController, env: Env, ctx: ExecutionContext) {
		const RAY = BigInt(10) ** BigInt(27);

		const liquidatorAccount = privateKeyToAccount(env.LIQUIDATOR_PRIVATE_KEY as `0x{string}`);

		const pools = [env.BTC_POOL_ADDRESS, env.ETH_POOL_ADDRESS, env.USDC_POOL_ADDRESS];
		const controller = env.CONTROLLER_ADDRESS;

		const publicClient = createPublicClient({
			chain: scrollSepolia,
			transport: http(env.SCROLL_SEPOLIA_RPC_URL),
		});

		const walletClient = createWalletClient({
			chain: scrollSepolia,
			transport: http(env.SCROLL_SEPOLIA_RPC_URL),
			account: liquidatorAccount,
		});

		const events = [];
		for (const pool of pools) {
			const individualPoolEvents = await publicClient.getContractEvents({
				address: pool,
				abi: poolABI,
				eventName: 'BorrowIntentPosted',
				fromBlock: BigInt(env.FROM_BLOCK),
			});

			events.push(individualPoolEvents);
		}

		const borrowIntents = events.flat();
		const watchlist = Array.from(new Set(borrowIntents.map((borrowIntent) => getAddress('0x' + borrowIntent.topics[1]?.slice(26)))));

		const healthFactors = await Promise.all(
			watchlist.map((address) =>
				publicClient.readContract({
					address: controller,
					abi: controllerABI,
					functionName: 'healthFactorFor',
					args: [address],
				}),
			),
		);

		const liquidationCandidates = watchlist.filter((_, index) => (healthFactors[index] as bigint) < RAY);
		for (const candidate of liquidationCandidates) {
			const { request } = await publicClient.simulateContract({
				account: liquidatorAccount,
				address: controller,
				abi: controllerABI,
				functionName: 'liquidate',
				args: [candidate],
				value: BigInt(0),
			});

			const hash = await walletClient.writeContract(request);

			await publicClient.waitForTransactionReceipt({ hash });
		}
	},
};
