import * as dotenv from "dotenv";
import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "@openzeppelin/hardhat-upgrades";
import { getEnv } from "./lib/utils";

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
  },
};

export default config;
