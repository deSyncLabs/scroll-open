import { createPublicClient, createWalletClient, http } from 'viem';
import { privateKeyToAccount } from 'viem/accounts';
import { scrollSepolia } from 'viem/chains';
import { poolABI } from './abis';

export default {
	async scheduled(_: ScheduledController, env: Env, ctx: ExecutionContext) {
		const adminAccount = privateKeyToAccount(env.ADMIN_PRIVATE_KEY);
		const publicClient = createPublicClient({
			chain: scrollSepolia,
			transport: http(env.SCROLL_SEPOLIA_RPC_URL),
		});
		const walletClient = createWalletClient({
			chain: scrollSepolia,
			transport: http(env.SCROLL_SEPOLIA_RPC_URL),
			account: adminAccount,
		});

		const ethPoolAddress = '0x8CeA85eC7f3D314c4d144e34F2206C8Ac0bbadA1';

		const data = await publicClient.readContract({
			address: ethPoolAddress,
			abi: poolABI,
			functionName: 'locked',
		});

		console.log('before: ', data);

		// try {
		// 	const { request } = await publicClient.simulateContract({
		// 		account: adminAccount,
		// 		address: ethPoolAddress,
		// 		abi: poolABI,
		// 		functionName: 'executeStratergy',
		// 	});

		// 	const hash = await walletClient.writeContract(request);
		// 	console.log('hash: ', hash);

		// 	await publicClient.waitForTransactionReceipt({ hash });
		// } catch (e) {
		// 	console.error(e);
		// }

		const dataAfter = await publicClient.readContract({
			address: ethPoolAddress,
			abi: poolABI,
			functionName: 'locked',
		});

		console.log('after: ', dataAfter);

		const events = await publicClient.getContractEvents({
			address: ethPoolAddress,
			abi: poolABI,
			fromBlock: BigInt(8447199),
			toBlock: BigInt(8447300),
		});

		console.log('events: ', events);
	},
};
