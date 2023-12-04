import hre, { ethers, upgrades } from "hardhat";
import { pn, prompt } from "../../lib/utils";
import { getEnv } from "../../lib/utils";
import { Deployer } from "@matterlabs/hardhat-zksync-deploy";
import * as dotenv from "dotenv";
import { Wallet } from "zksync-web3";

async function main() {
  const network = await ethers.provider.getNetwork();
  const networkName = hre.network.name;
  let account;
  let accountAddress;

  // Initialize the wallet
  const testMnemonic =
    "stick toy mercy cactus noodle company pear crawl tide deny pipe name";
  const zkWallet = new Wallet(process.env.DEPLOYER_PRIVATE_KEY ?? testMnemonic);

  // Create a deployer object
  account = new Deployer(hre, zkWallet);

  accountAddress = zkWallet.address;
  const balance = await ethers.provider.getBalance(accountAddress);

  console.log(`chainId: ${network.chainId}`);
  console.log(`network: ${networkName} (from ethers: ${network.name})`);
  console.log(`account: ${accountAddress}`);
  console.log(`balance: ${pn(balance.toString())}`);

  await prompt("do you want to deploy the MultiRoundCheckout contract?");
  console.log("deploying...");

  const MultiRoundCheckout = await account.loadArtifact("MultiRoundCheckout");

  const MRCDeploymentFee = await account.estimateDeployFee(
    MultiRoundCheckout,
    []
  );

  const parsedMRCFee = ethers.formatEther(MRCDeploymentFee);
  console.info(`Estimated deployment fee: ${parsedMRCFee} ETH`);

  // Deploy the contract
  const MRCContractDeployment = await account.deploy(MultiRoundCheckout, []);

  await MRCContractDeployment.deployed();

  // Show the contract info
  console.info(
    "MRCContractDeployment deployed to:",
    MRCContractDeployment.address
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
