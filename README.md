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
