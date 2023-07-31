# Allo MultiRoundCheck

TODO

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

