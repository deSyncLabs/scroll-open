.PHONY: borrow withdraw

borrow:
	. .env && forge script script/DistributeBorrow.s.sol --rpc-url $$SCROLL_SEPOLIA_RPC_URL --private-keys $$DISTRIBUTOR_EOA_PRIVATE_KEY --broadcast -vv

withdraw:
	. .env && forge script script/DistributeWithdraw.s.sol --rpc-url $$SCROLL_SEPOLIA_RPC_URL --private-keys $$DISTRIBUTOR_EOA_PRIVATE_KEY --broadcast -vv
