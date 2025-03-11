FROM ghcr.io/foundry-rs/foundry:latest

WORKDIR /app

COPY . .

ARG REBALANCER_EOA_PRIVATE_KEY
ARG POOL_ADDRESS
ARG SCROLL_SEPOLIA_RPC_URL

ENV REBALANCER_EOA_PRIVATE_KEY=$REBALANCER_EOA_PRIVATE_KEY
ENV POOL_ADDRESS=$POOL_ADDRESS
ENV SCROLL_SEPOLIA_RPC_URL=$SCROLL_SEPOLIA_RPC_URL


RUN forge install OpenZeppelin/openzeppelin-contracts

CMD ["forge", "script", "script/Rebalancer.s.sol", "--rpc-url", "$SCROLL_SEPOLIA_RPC_URL", "--private-keys", "$REBALANCER_EOA_PRIVATE_KEY", "--broadcast"]