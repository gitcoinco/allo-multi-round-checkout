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

| Chain             | Address                                    |
|-------------------|--------------------------------------------|
| Ethereum          | 0x3bA9DF642f5e895DC76d3Aa9e4CE8291108E65b1 |
| PGN               | 0x03506eD3f57892C85DB20C36846e9c808aFe9ef4 |
| Optimism          | 0x15fa08599EB017F89c1712d0Fe76138899FdB9db |
| Fantom            | 0x03506eD3f57892C85DB20C36846e9c808aFe9ef4 |
| Fantom Testnet    | 0x62a850d7805f3Ae382C6eEf7eEB89A31f68Ce2d5 |
| Arbitrum One      | 0x8e1bD5Da87C14dd8e08F7ecc2aBf9D1d558ea174 |
| Sepolia           | 0xa54A0c7Bcd37745f7F5817e06b07E2563a07E309 |
| PGN Testnet       | 0x4268900E904aD87903De593AA5424406066d9ea2 |
| Arbitrum Goerli   | 0x8e1bD5Da87C14dd8e08F7ecc2aBf9D1d558ea174 |
| Polygon Mumbai    | 0x8e1bD5Da87C14dd8e08F7ecc2aBf9D1d558ea174 |
| Polygon           | 0xe04d9e9CcDf65EB1Db51E56C04beE4c8582edB73 |
| Avalanche Fuji    | 0x8e1bD5Da87C14dd8e08F7ecc2aBf9D1d558ea174 |
| Avalanche         | 0xe04d9e9CcDf65EB1Db51E56C04beE4c8582edB73 |
| Base Goerli       | 0xa63f8F7E90C538D5173c7467C228fd38422dE9e9 |
| Base              | 0x7C24f3494CC958CF268a92b45D7e54310d161794 |
| zkSyncEra Sepolia | 0x32e93A37dc02f97b8EDe446D8e468B1a894b47e0 |
| zkSyncEra         | 0x9FD009C448ce9b5DD7D609BFaf7C1C8fb91fb3ff |
| Scroll Sepolia    | 0x8Bd6Bc246FAF14B767954997fF3966CD1c0Bf0f5 |
| Scroll            | 0x8Bd6Bc246FAF14B767954997fF3966CD1c0Bf0f5 |
| Celo Alfajores    | 0x8Ad0a1111B3d8453Ea9C444cA7d708A65BF81Def |
| Celo              | 0xb1481E4Bb2a018670aAbF68952F73BE45bdAD62D |
| Lukso             | 0x029dFAf686DfA0efdace5132ba422e9279D50b5b |
| Lukso Testnet     | 0xC1087157eF2aaeBcaDB913251EA5B82c678424F7 |
| Filecoin Calibration | 0x2447dD8C1f4cd4361a649564Bd441787edf8c03A |
| Sei Devnet        | 0x313eC6CA225C40Bc670d8cd4b063734BD22ad1ab |
| Sei Mainnet       | 0x1E18cdce56B3754c4Dca34CB3a7439C24E8363de |
| Metis Andromeda   | 0x710172b2C0aCc629A3FD23D436c347807dD5C412 |



