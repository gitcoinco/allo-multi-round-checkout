import hre, { ethers, upgrades } from "hardhat";
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
  console.log("deploying...");

  const MultiRoundCheckout = await ethers.getContractFactory(
    "MultiRoundCheckout",
    account
  );
  const instance = await upgrades.deployProxy(MultiRoundCheckout, []);
  await instance.waitForDeployment();

  const tx = instance.deploymentTransaction();
  if (tx === null) {
    console.error("cannot fetch deployTransaction");
    return;
  }

  const rec = await tx.wait();
  if (rec === null) {
    console.error("cannot fetch receipt");
    return;
  }

  const address = await instance.getAddress();

  console.log("tx hash", tx.hash);
  const gas = pn(rec.gasUsed.toString());
  console.log(`gas used: ${gas}`);

  console.log("MultiRoundCheckout to:", address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
