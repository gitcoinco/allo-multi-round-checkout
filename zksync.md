## Deployment on zkSync Era Testnet

**Compile**
`npx hardhat compile --network zkSyncTestnet --config era.hardhat.config.ts `

**Deploy**
`npx hardhat deploy-zksync --network zkSyncTestnet --config era.hardhat.config.ts --script deployZkSync.ts`

**Verify**
`npx hardhat verify --network zkSyncTestnet --config era.hardhat.config.ts 0x..`

## Deployment on zkSync Era Mainnet

**Compile**
`npx hardhat compile --network zkSyncMainnet --config era.hardhat.config.ts `

**Deploy**
`npx hardhat deploy-zksync --network zkSyncMainnet --config era.hardhat.config.ts --script deployZkSync.ts`

**Verify**
`npx hardhat verify --network zkSyncMainnet --config era.hardhat.config.ts 0x..`