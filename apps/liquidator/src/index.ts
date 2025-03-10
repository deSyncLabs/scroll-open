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

		const borrowIntentEventsPromises = [];
		for (const pool of pools) {
			borrowIntentEventsPromises.push(
				publicClient.getContractEvents({
					address: pool,
					abi: poolABI,
					eventName: 'BorrowIntentPosted',
					fromBlock: BigInt(env.FROM_BLOCK),
				}),
			);
		}

		const borrowIntentEvents = await Promise.all(borrowIntentEventsPromises);
		const borrowIntents = borrowIntentEvents.flat();

		const watchList = [];
		for (const borrowIntent of borrowIntents) {
			const address = getAddress('0x' + borrowIntent.topics[1]?.slice(26));
			watchList.push(address);
		}

		const cleanWatchList = Array.from(new Set(watchList));

		const healthFactorPromises = [];
		for (const address of cleanWatchList) {
			healthFactorPromises.push(
				publicClient.readContract({
					address: controller,
					abi: controllerABI,
					functionName: 'healthFactorFor',
					args: [address],
				}),
			);
		}

		const healthFactors: bigint[] = (await Promise.all(healthFactorPromises)) as bigint[];

		const liquidationCandidates = [];
		for (let i = 0; i < cleanWatchList.length; i++) {
			if (healthFactors[i] < RAY) {
				liquidationCandidates.push(cleanWatchList[i]);
			}
		}

		if (liquidationCandidates.length <= 0) {
			return;
		}

		const liquidationPromises = [];
		for (const address of liquidationCandidates) {
			liquidationPromises.push(
				publicClient.simulateContract({
					account: liquidatorAccount,
					address: controller,
					abi: controllerABI,
					functionName: 'liquidate',
					args: [address],
				}),
			);
		}

		const liquidationRequests = await Promise.all(liquidationPromises);

		const receiptPromises = [];
		for (const request of liquidationRequests) {
			const hash = await walletClient.writeContract(request.request);
			receiptPromises.push(publicClient.waitForTransactionReceipt({ hash }));
		}

		ctx.waitUntil(Promise.all(receiptPromises));
	},
};
