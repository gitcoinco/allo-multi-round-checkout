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
    arbitrumTestnet: {
      url: getEnv("ARBITRUM_TESTNET_RPC_URL"),
      ledgerAccounts: [getEnv("HARDWARE_WALLET_ACCOUNT", ethers.ZeroAddress)],
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
    fantomTestnet: {
      url: getEnv("FANTOM_TESTNET_RPC_URL"),
      ledgerAccounts: [getEnv("HARDWARE_WALLET_ACCOUNT", ethers.ZeroAddress)],
    },
    mainnet: {
      url: getEnv("MAINNET_RPC_URL"),
      ledgerAccounts: [getEnv("HARDWARE_WALLET_ACCOUNT", ethers.ZeroAddress)],
    },
    arbitrumOne: {
      url: getEnv("ARBITRUM_ONE_RPC_URL"),
      ledgerAccounts: [getEnv("HARDWARE_WALLET_ACCOUNT", ethers.ZeroAddress)],
    },
    polygonMumbai: {
      url: getEnv("POLYGON_MUMBAI_RPC_URL"),
      ledgerAccounts: [getEnv("HARDWARE_WALLET_ACCOUNT", ethers.ZeroAddress)],
    },
    polygon: {
      url: getEnv("POLYGON_RPC_URL"),
      ledgerAccounts: [getEnv("HARDWARE_WALLET_ACCOUNT", ethers.ZeroAddress)],
    },
    avalancheFuji: {
      url: getEnv("AVALANCHE_FUJI_RPC_URL"),
      ledgerAccounts: [getEnv("HARDWARE_WALLET_ACCOUNT", ethers.ZeroAddress)],
    },
    avalanche: {
      url: getEnv("AVALANCHE_RPC_URL"),
      ledgerAccounts: [getEnv("HARDWARE_WALLET_ACCOUNT", ethers.ZeroAddress)],
    },
  },
  etherscan: {
    apiKey: {
      mainnet: getEnv("ETHERSCAN_ETHEREUM_API_KEY", ""),
      optimisticEthereum: getEnv("ETHERSCAN_OPTIMISM_API_KEY", ""),
      opera: getEnv("ETHERSCAN_FANTOM_API_KEY"),
      polygon: getEnv("ETHERSCAN_POLYGON_API_KEY"),
      avalanche: getEnv("ETHERSCAN_AVALANCHE_API_KEY"),
    },
  },
};

export default config;
