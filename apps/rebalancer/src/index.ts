import { createPublicClient, createWalletClient, http } from 'viem';
import { privateKeyToAccount } from 'viem/accounts';
import { scrollSepolia } from 'viem/chains';
import { poolABI , mintableERC20ABI} from './abis';

export default {
	async scheduled(_: ScheduledController, env: Env, ctx: ExecutionContext) {
		const pools = [env.BTC_POOL_ADDRESS, env.ETH_POOL_ADDRESS, env.USDC_POOL_ADDRESS];

		const adminAccount = privateKeyToAccount(env.ADMIN_PRIVATE_KEY as `0x{string}`);
		const publicClient = createPublicClient({
			chain: scrollSepolia,
			transport: http(env.SCROLL_SEPOLIA_RPC_URL),
		});
		const walletClient = createWalletClient({
			chain: scrollSepolia,
			transport: http(env.SCROLL_SEPOLIA_RPC_URL),
			account: adminAccount,
		});

		try {
			for (const pool of pools) {
				const { request } = await publicClient.simulateContract({
					account: adminAccount,
					address: pool,
					abi: poolABI,
					functionName: 'unexecuteStratergy',
				});
				const hash = await walletClient.writeContract(request);
				ctx.waitUntil(publicClient.waitForTransactionReceipt({ hash }));
			}

			for (const pool of pools) {
				const { request } = await publicClient.simulateContract({
					account: adminAccount,
					address: pool,
					abi: poolABI,
					functionName: 'borrowForEveryone',
				});
				const hash = await walletClient.writeContract(request);
				ctx.waitUntil(publicClient.waitForTransactionReceipt({ hash }));
			}

			for (const pool of pools) {
				const { request } = await publicClient.simulateContract({
					account: adminAccount,
					address: pool,
					abi: poolABI,
					functionName: 'withdrawForEveryone',
				});
				const hash = await walletClient.writeContract(request);
				ctx.waitUntil(publicClient.waitForTransactionReceipt({ hash }));
			}

			const data = await publicClient.readContract({
				address: '0x91A1EeE63f300B8f41AE6AF67eDEa2e2ed8c3f79',
				abi: mintableERC20ABI,
				functionName: 'balanceOf',
				args: [pools[1]],
			});

			console.log("am: ",data);

			for (const pool of pools) {
				const { request } = await publicClient.simulateContract({
					account: adminAccount,
					address: pool,
					abi: poolABI,
					functionName: 'executeStratergy',
				});
				const hash = await walletClient.writeContract(request);
				ctx.waitUntil(publicClient.waitForTransactionReceipt({ hash }));
			}
		} catch (e) {
			console.error(e);
		}
	},
};
