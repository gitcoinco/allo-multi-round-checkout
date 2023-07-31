# Allo MultiRoundCheck

The MultiRoundCheckout contract is a smart contract designed to simplify the process of donating to multiple rounds on the Allo V1 protocol
and voting with ERC20 tokens.
It streamlines the donation and voting process by enabling users to perform these actions using a single transaction,
eliminating the need to send multiple transactions for each round.

## Features

1. **Multiple Rounds with one transatction**: With MultiRoundCheckout, users can donate to multiple rounds on the Allo V1 protocol using just one transaction, saving time and gas fees.

2. **ERC20 permit/donate in one transaction**: Instead of executing separate transactions for token approval and donation, users can now vote with ERC20 tokens in a single transaction.
The contract supports ERC20 permit-compatible tokens, specifically those implementing ERC-2612 or DAI permit.
This enables users to sign a "permit" message, simplifying the token approval process, saving gas fees and reducing the number of transactions needed to donate.

## Setup

```
git clone
git submodule update --init --recursive
npm i
```

## Tests

```
forge test
```

## Deployment gas benchmark

```
npx hardhat run scripts/gas-bench.ts --typecheck
```

## Donations gas benchmarks

```
# fork mainnet during the Gitcoin Beta rounds
npx hardhat node --fork https://mainnet.infura.io/v3/$INFURA_API_KEY --fork-block-number 17123359

# run the benchmarks against the local fork
npx hardhat run scripts/benchmarks/beta-rounds-bench.ts --network localhost
```

## Deployments

| Chain       | Address                                    |
|-------------|--------------------------------------------|
| Goerli      | 0x69433D914c7Cd8b69710a3275bcF3df4CB3eDA94 |
| PGN Testnet | 0x4268900E904aD87903De593AA5424406066d9ea2 |

