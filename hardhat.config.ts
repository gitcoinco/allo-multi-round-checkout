import * as dotenv from "dotenv";
import { HardhatUserConfig } from "hardhat/config";
import "@openzeppelin/hardhat-upgrades";
import { getEnv } from "./lib/utils";
import "@nomicfoundation/hardhat-ledger";
import { ethers } from "ethers";

dotenv.config();

const account = () => {
  if (process.env.PRIVATE_KEY) {
    return [getEnv("PRIVATE_KEY")];
  } else {
    return {
      mnemonic: getEnv("MNEMONIC"),
    };
  }
};

const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.20",
    settings: {
      optimizer: {
        enabled: true,
        runs: 400,
      },
    },
  },
  networks: {
    hardhat: {},
    localhost: {
      accounts: account(),
    },
    sepolia: {
      url: getEnv("SEPOLIA_RPC_URL"),
      accounts: account(),
    },
    pgnTestnet: {
      url: getEnv("PGN_TESTNET_RPC_URL"),
      accounts: account(),
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
    baseSepolia: {
      url: getEnv("BASE_SEPOLIA_RPC_URL"),
      accounts: account(),
    },
    baseGoerli: {
      url: getEnv("BASE_GOERLI_RPC_URL"),
      accounts: account(),
    },
    base: {
      url: getEnv("BASE_RPC_URL"),
      ledgerAccounts: [getEnv("HARDWARE_WALLET_ACCOUNT", ethers.ZeroAddress)],
    },
    scrollSepolia: {
      url: getEnv("SCROLL_SEPOLIA_RPC_URL"),
      accounts: account(),
    },
    scroll: {
      url: getEnv("SCROLL_RPC_URL"),
      ledgerAccounts: [getEnv("HARDWARE_WALLET_ACCOUNT", ethers.ZeroAddress)],
    },
    seiDevnet: {
      url: getEnv("SEI_DEVNET_RPC_URL"),
      accounts: account(),
    },
    celo: {
      url: getEnv("CELO_RPC_URL"),
      accounts: account(),
    },
    celoAlfajores: {
      url: getEnv("CELO_ALFAJORES_RPC_URL"),
      accounts: account(),
    },
    filecoin: {
      url: getEnv("FILECOIN_RPC_URL"),
      accounts: account(),
    },
    filecoinTestnet: {
      url: getEnv("FILECOIN_TESTNET_RPC_URL"),
      accounts: account(),
    },
    lukso: {
      url: getEnv("LUKSO_RPC_URL"),
      accounts: account(),
    },
    luksoTestnet: {
      url: getEnv("LUKSO_TESTNET_RPC_URL"),
      accounts: account(),
    },
  },
  etherscan: {
    apiKey: {
      mainnet: getEnv("ETHERSCAN_ETHEREUM_API_KEY", ""),
      sepolia: getEnv("ETHERSCAN_ETHEREUM_API_KEY", ""),
      optimisticEthereum: getEnv("ETHERSCAN_OPTIMISM_API_KEY", ""),
      opera: getEnv("ETHERSCAN_FANTOM_API_KEY"),
      ftmTestnet: getEnv("ETHERSCAN_FANTOM_API_KEY"),
      polygon: getEnv("ETHERSCAN_POLYGON_API_KEY"),
      polygonMumbai: getEnv("ETHERSCAN_POLYGON_API_KEY"),
      avalanche: getEnv("ETHERSCAN_AVALANCHE_API_KEY"),
      base: getEnv("ETHERSCAN_BASE_API_KEY"),
      scrollSepolia: getEnv("ETHERSCAN_SCROLL_API_KEY"),
      scroll: getEnv("ETHERSCAN_SCROLL_API_KEY"),
      arbitrumOne: getEnv("ETHERSCAN_ARBITRUM_API_KEY"),
    },
    customChains: [
      {
        network: "base",
        chainId: 8453,
        urls: {
          apiURL: "https://api.basescan.org/api",
          browserURL: "https://basescan.org",
        },
      },
      {
        network: "arbitrumOne",
        chainId: 42161,
        urls: {
          apiURL: "https://api.arbiscan.io/api",
          browserURL: "https://arbiscan.io",
        },
      },
      {
        network: "scrollSepolia",
        chainId: 534351,
        urls: {
          apiURL: "https://sepolia.scrollscan.com/api",
          browserURL: "https://sepolia.scrollscan.com",
        },
      },
      {
        network: "scroll",
        chainId: 534352,
        urls: {
          apiURL: "https://api.scrollscan.com/api",
          browserURL: "https://scrollscan.com",
        },
      },
    ],
  },
};

export default config;
