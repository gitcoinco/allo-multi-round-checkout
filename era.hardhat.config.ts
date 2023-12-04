import * as dotenv from "dotenv";

import "@matterlabs/hardhat-zksync-deploy";
import "@matterlabs/hardhat-zksync-solc";
import "@matterlabs/hardhat-zksync-upgradable";
import "@matterlabs/hardhat-zksync-verify";
import "@typechain/hardhat";
import { HardhatUserConfig } from "hardhat/config";
import { NetworkUserConfig } from "hardhat/types";
import "solidity-coverage";

import { getEnv } from "./lib/utils";
import "@nomicfoundation/hardhat-ledger";
import { ethers } from "ethers";

dotenv.config();

const chainIds = {
  // testnet
  "zksync-testnet": 280,
  // mainnet
  "zksync-mainnet": 324,
};

let deployPrivateKey = process.env.DEPLOYER_PRIVATE_KEY as string;
if (!deployPrivateKey) {
  deployPrivateKey =
    "0x0000000000000000000000000000000000000000000000000000000000000001";
}

const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.18",
    settings: {
      optimizer: {
        enabled: true,
        runs: 400,
      },
    },
  },
  networks: {
    // Main Networks
    "zksync-mainnet": {
      accounts: [deployPrivateKey],
      chainId: chainIds["zksync-mainnet"],
      url: `https://zksync2-mainnet.zksync.io`,
      zksync: true,
      ethNetwork: "mainnet",
      verifyURL:
        "https://zksync2-mainnet-explorer.zksync.io/contract_verification",
    },

    // Test Networks
    "zksync-testnet": {
      accounts: [deployPrivateKey],
      chainId: chainIds["zksync-testnet"],
      url: `https://zksync2-testnet.zksync.dev`,
      allowUnlimitedContractSize: true,
      zksync: true,
      ethNetwork: "goerli",
      verifyURL:
        "https://zksync2-testnet-explorer.zksync.dev/contract_verification",
    },
  },
  defaultNetwork: "zksync-testnet",
  gasReporter: {
    enabled: process.env.REPORT_GAS !== undefined,
    currency: "USD",
  },
  etherscan: {
    apiKey: {
      mainnet: getEnv("ETHERSCAN_ETHEREUM_API_KEY", ""),
      goerli: getEnv("ETHERSCAN_ETHEREUM_API_KEY", ""),
    },
  },
  zksolc: {
    version: "1.3.13",
    compilerSource: "binary",
    settings: {
      isSystem: true,
    },
  },
};

export default config;
