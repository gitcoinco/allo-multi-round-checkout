import hre, { ethers, upgrades } from "hardhat";
import { pn, prompt } from "../../lib/utils";
import { getEnv } from "../../lib/utils";

// Script to transfer ownership of Ownable contracts.
// It can be used both for ProxyAdmin and MultiRoundCheckout contracts.

const CONTRACT_ADDRESS = "";
const NEW_OWNER_ADDRESS = "";

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

  console.log(account.address);

  accountAddress = account.address;
  const balance = await ethers.provider.getBalance(accountAddress);

  console.log(`chainId: ${network.chainId}`);
  console.log(`network: ${networkName} (from ethers: ${network.name})`);
  console.log(`account: ${accountAddress}`);
  console.log(`balance: ${pn(balance.toString())}`);

  await prompt(
    `do you want to transfer ownership of the contract at ${CONTRACT_ADDRESS} to address ${NEW_OWNER_ADDRESS}?`
  );
  console.log("init...");

  const contract = await ethers.getContractAt(
    "MultiRoundCheckout",
    CONTRACT_ADDRESS,
    account
  );

  console.log("current owner ", await contract.owner());

  const tx = await contract.transferOwnership(NEW_OWNER_ADDRESS);
  const rec = await tx.wait();
  if (rec === null) {
    console.error("cannot fetch receipt");
    return;
  }

  console.log("tx hash", tx.hash);
  const gas = pn(rec.gasUsed.toString());
  console.log(`gas used: ${gas}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
