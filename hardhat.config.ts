import * as dotenv from "dotenv";
import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "@openzeppelin/hardhat-upgrades";
import { getEnv } from "./lib/utils";
import "@nomicfoundation/hardhat-ledger";
import { ethers } from "ethers";

dotenv.config();

const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.18",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
  networks: {
    hardhat: {},
    localhost: {
      accounts: {
        mnemonic: getEnv("MNEMONIC"),
      },
    },
    goerli: {
      url: getEnv("GOERLI_RPC_URL"),
      accounts: {
        mnemonic: getEnv("MNEMONIC"),
      },
    },
    pgnTestnet: {
      url: getEnv("PGN_TESTNET_RPC_URL"),
      accounts: {
        mnemonic: getEnv("MNEMONIC"),
      },
      // gasPrice: 1000000000,
    },
    pgn: {
      url: getEnv("PGN_RPC_URL"),
      ledgerAccounts: [getEnv("HARDWARE_WALLET_ACCOUNT", ethers.ZeroAddress)],
      // gas: 3_000_000,
      // gasPrice: 1_800000000,
    },
    optimism: {
      url: getEnv("OPTIMISM_RPC_URL"),
      ledgerAccounts: [getEnv("HARDWARE_WALLET_ACCOUNT", ethers.ZeroAddress)],
    },
    fantom: {
      url: getEnv("FANTOM_RPC_URL"),
      ledgerAccounts: [getEnv("HARDWARE_WALLET_ACCOUNT", ethers.ZeroAddress)],
    },
    mainnet: {
      url: getEnv("MAINNET_RPC_URL"),
      ledgerAccounts: [getEnv("HARDWARE_WALLET_ACCOUNT", ethers.ZeroAddress)],
    },
  },
  etherscan: {
    apiKey: {
      mainnet: getEnv("ETHERSCAN_ETHEREUM_API_KEY", ""),
      optimisticEthereum: getEnv("ETHERSCAN_OPTIMISM_API_KEY", ""),
      opera: getEnv("ETHERSCAN_FANTOM_API_KEY"),
    },
  },
};

export default config;
