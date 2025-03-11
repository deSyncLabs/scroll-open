.PHONY: anvil scroll-sepolia

anvil:
	. .env && forge script script/Deploy.s.sol --rpc-url $$ANVIL_RPC_URL --private-keys $$DEPLOYER_PRIVATE_KEY --private-keys $$ADMIN_PRIVATE_KEY --broadcast --optimize

scroll-sepolia:
	. .env && forge script script/Deploy.s.sol --rpc-url $$SCROLL_SEPOLIA_RPC_URL --private-keys $$DEPLOYER_PRIVATE_KEY --private-keys $$ADMIN_PRIVATE_KEY --broadcast --optimize --verify --verifier etherscan --verifier-url $$SCROLLSCAN_API_URL --etherscan-api-key $$SCROLLSCAN_API_KEY