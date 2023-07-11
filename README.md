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

## Gas Bench

```
npx hardhat node --fork https://mainnet.infura.io/v3/$INFURA_API_KEY
npx hardhat run scripts/gas-bench.ts --typecheck
```
