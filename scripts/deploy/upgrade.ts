import hre, { ethers, upgrades } from "hardhat";
import { pn, prompt } from "../../lib/utils";
import { getEnv } from "../../lib/utils";

async function main() {
  const network = await ethers.provider.getNetwork();
  const networkName = hre.network.name;
  const MRC_PROXY_ADDRESS = ""; // TODO: Upgrade the MultiRoundCheckout contract

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

  await prompt("do you want to upgrade the MultiRoundCheckout contract?");

  console.log("Upgrading MultiRoundCheckout...");

  const newMultiRoundCheckout = await ethers.getContractFactory(
    "MultiRoundCheckout"
  );

  await upgrades.upgradeProxy(MRC_PROXY_ADDRESS, newMultiRoundCheckout, {
    unsafeAllowRenames: true,
  });

  console.log("MultiRoundCheckout upgraded");
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
