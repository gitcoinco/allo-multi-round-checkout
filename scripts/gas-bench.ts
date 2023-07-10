import { ethers } from "hardhat";
import { ContractTransactionResponse } from "ethers";

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

const deploy = async (contractName: string) => {
  const contract = await ethers.deployContract(contractName, [], {});
  await gasBench(`🚀 deploy ${bold(contractName)}`, async () => {
    await contract.waitForDeployment();
    return contract.deploymentTransaction();
  });

  return contract;
};

async function voteWithMultiRoundCheckoutContract() {
  const [user] = await ethers.getSigners();
  console.log(
    "user balance",
    pn(await ethers.provider.getBalance(user.address))
  );

  const contract = await deploy("MultiRoundCheckout");

  // TODO: when the fork setup is done, use the actual rounds instead of the mocks
  const round1 = await deploy("MockRoundImplementation");
  const round2 = await deploy("MockRoundImplementation");
  const round3 = await deploy("MockRoundImplementation");

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

  await gasBench("✅ vote", () =>
    contract.vote(votes, rounds, amounts, {
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
