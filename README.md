# PeppySwapV1
PeppySwapV1 is a clone of uniswapV1 which is a decentralized exchange (DEX) that aims to be an alternative to centralized exchanges. It’s runs on different EVM blockchains such as ethereum, polygon, binance smart chain and some layer2 blockchains such as base, optimism    and it’s fully automated: there are no admins, managers, or users with privileged access.

On the lower lever, it’s an algorithm that allows to make pools, or token pairs, and fill them with liquidity to let users exchange tokens using this liquidity. Such algorithm is called automated market maker or automated liquidity provider.

UniswapV1 only allows swaps between ether and an ERC20 token but then there are chained swaps which is how ERC20 tokens are swaped for each other, what actually happens is that the owner token is swapped to ether first then the ether is swapped to the needed ERC20 token.

