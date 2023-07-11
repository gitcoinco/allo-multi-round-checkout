import { ethers } from "hardhat";
import { ethers as ethersns } from "ethers";

import { ContractTransactionResponse } from "ethers";
import { MultiRoundCheckout } from "../typechain-types";
import {
  impersonateAccount,
  setBalance,
} from "@nomicfoundation/hardhat-network-helpers";

const ROUNDS = [
  "0x6e8dC2e623204D61b0E59E668702654aE336c9f7", // desci
  "0x421510312C40486965767be5Ea603Aa8a5707983", // climate
  "0xAA40E2E5c8df03d792A52B5458959C320F86ca18", // web3 community and education
  "0xdf22a2C8F6BA9376fF17EE13E6154B784ee92094", // ethereum infra
];

// pretty number
const pn = (n: bigint) => n.toString().replace(/\B(?=(\d{3})+(?!\d))/g, "_");

const gasBench = async (
  msg: string,
  callback: () => Promise<ContractTransactionResponse | null>
) => {
  const tx = await callback();
  if (tx === null) {
    throw "failed to execute transaction";
  }

  const rec = await tx.wait();
  if (rec === null) {
    throw "failed to retrieve transaction receipt";
  }

  console.log(msg, "🛢️ ", pn(rec.gasUsed));
};

const bold = (s: string) => `\x1b[1m${s}\x1b[0m`;

const deploy = async (contractName: string, signer: ethersns.Signer) => {
  const contract: MultiRoundCheckout = await ethers.deployContract(
    contractName,
    [],
    signer
  );

  await gasBench(
    `🚀 deploy ${bold(contractName)} (${contract.target})`,
    async () => {
      await contract.waitForDeployment();
      return contract.deploymentTransaction();
    }
  );

  return contract;
};

const impersonate = async (addresses: string[]) => {
  for (const a of addresses) {
    await impersonateAccount(a);
    await setBalance(a, ethers.parseEther("10"));
    console.log(`${a} balance`, pn(await ethers.provider.getBalance(a)));
  }
};

async function voteWithMultiRoundCheckoutContract() {
  const deployerAddress = "0x79427367e9Be16353336D230De3031D489b1b3c3";
  const deployer = await ethers.getImpersonatedSigner(deployerAddress);
  await impersonate([deployerAddress]);

  const [user] = await ethers.getSigners();

  const contract = await deploy("MultiRoundCheckout", deployer);
  const round1 = await deploy("MockRoundImplementation", deployer);
  const round2 = await deploy("MockRoundImplementation", deployer);
  const round3 = await deploy("MockRoundImplementation", deployer);

  // const vote = [
  //   "0x0000000000000000000000000000000000000000",
  //   ethers.parseEther("1"),
  //   projectAddress,
  //   "0x1111111111111111111111111111111111111111111111111111111111111111",
  //   "0x123",
  // ];

  // encodedVotes.push(
  //   ethers.defaultAbiCoder.encode(
  //     ["address", "uint256", "address", "bytes32", "uint256"],
  //     vote
  //   )
  // );

  const votes = [
    ["0x01", "0x02", "0x03"],
    ["0x01", "0x02", "0x03"],
    ["0x01", "0x02", "0x03"],
  ];

  const rounds = [round1.target, round2.target, round3.target];

  const amounts = [
    ethers.parseEther("1"),
    ethers.parseEther("2"),
    ethers.parseEther("3"),
  ];

  console.log(
    `contract balance`,
    pn(await ethers.provider.getBalance(contract.target))
  );

  await gasBench("✅ vote", () =>
    contract.connect(user).vote(votes, rounds, amounts, {
      value: ethers.parseEther("6"),
    })
  );
}

async function main() {
  // Execute the following actions in fork from a block within the Beta rounds voting period.

  // await voteWithBetaRoundsContracts();
  await voteWithMultiRoundCheckoutContract();
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
