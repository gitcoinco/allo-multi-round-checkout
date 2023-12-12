import { Wallet } from "zksync2-js";
import hre, { ethers } from "hardhat";
import { Deployer } from "@matterlabs/hardhat-zksync-deploy";
import { pn, prompt } from "../../lib/utils";
import { getEnv } from "../../lib/utils";

async function main() {
  const network = await ethers.provider.getNetwork();
  const networkName = hre.network.name;
  let account;
  let accountAddress;

  if (process.env.USE_HARDWARE_WALLET === "true") {
    // with hardware wallet
    console.log("Waiting for hardware wallet to connect...");
    // account = new LedgerSigner(ethers.provider);
    account = await ethers.getSigner(getEnv("HARDWARE_WALLET_ACCOUNT"));
  } else {
    // default without hardware wallet
    account = (await ethers.getSigners())[0];
  }

  accountAddress = account.address;
  const balance = await ethers.provider.getBalance(accountAddress);

  console.log(`chainId: ${network.chainId}`);
  console.log(`network: ${networkName} (from ethers: ${network.name})`);
  console.log(`account: ${accountAddress}`);
  console.log(`balance: ${pn(balance.toString())}`);

  await prompt("do you want to deploy the MultiRoundCheckout contract?");

  const baseWallet = ethers.Wallet.fromPhrase(
    hre.network.config.accounts.mnemonic
  );

  const wallet = new Wallet(baseWallet.privateKey);
  const deployer = new Deployer(hre, wallet);
  const MultiRoundCheckout = await deployer.loadArtifact("MultiRoundCheckout");
  const contractDeploymentFee = await deployer.estimateDeployFee(
      MultiRoundCheckout,
      []
  );

  const estimatedFee = ethers.formatEther(
    contractDeploymentFee.toString()
  );
  console.info(`Estimated deployment fee: ${estimatedFee} ETH`);

  console.log("deploying...");
  await hre.zkUpgrades.deployProxy(
    deployer.zkWallet,
    MultiRoundCheckout,
    []
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
