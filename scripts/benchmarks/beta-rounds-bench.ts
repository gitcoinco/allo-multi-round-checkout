import { ethers } from "hardhat";
import type { ethers } from "hardhat";

import { ethers as ethersns } from "ethers";

import { ContractTransactionResponse } from "ethers";
import {
  MultiRoundCheckout,
  IBetaRoundsRoundImplementation,
  MockERC20Permit,
} from "../../typechain-types";
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

  const gasUsed = rec.gasUsed;
  console.log(msg, "🛢️ ", pn(gasUsed));
  return gasUsed;
};

const signPermitEIP2612 = async (
  signer: ethers.Signer,
  contractAddress: string | ethersns.Addressable,
  erc20Name: string,
  owner: string | ethersns.Addressable,
  spender: string | ethersns.Addressable,
  value: bigint,
  nonce: bigint,
  deadline: bigint,
  chainId: bigint
) => {
  const domain = [
    { name: "name", type: "string" },
    { name: "version", type: "string" },
    { name: "chainId", type: "uint256" },
    { name: "verifyingContract", type: "address" },
  ];

  const types = {
    Permit: [
      { name: "owner", type: "address" },
      { name: "spender", type: "address" },
      { name: "value", type: "uint256" },
      { name: "nonce", type: "uint256" },
      { name: "deadline", type: "uint256" },
    ],
  };

  const domainData = {
    name: erc20Name,
    version: "1",
    chainId: chainId,
    verifyingContract: contractAddress.toString(),
  };

  const message = {
    owner,
    spender,
    value,
    nonce,
    deadline,
  };

  return await signer.signTypedData(domainData, types, message);
};

const bold = (s: string) => `\x1b[1m${s}\x1b[0m`;

const deploy = async (
  contractName: string,
  params: any[],
  signer: ethersns.Signer
) => {
  const contract = await ethers.deployContract(contractName, params, signer);

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

type Vote = [string, bigint, string, string, bigint];

const voteETHWithRounds = async (
  user: ethersns.Signer,
  roundsAddresses: string[],
  votes: Vote[][]
) => {
  console.log(
    "Voting with ETH using Round contract on",
    roundsAddresses.length,
    "rounds"
  );

  let totalCheckoutGas = 0n;

  for (let i = 0; i < roundsAddresses.length; i++) {
    const roundAddress = roundsAddresses[i];
    const roundVotes = votes[i];

    const encodedVotes: any = [];
    let totalAmountForRound = 0n;

    for (let j = 0; j < roundVotes.length; j++) {
      const roundVote = roundVotes[j];
      totalAmountForRound += roundVote[1];
      encodedVotes.push(
        ethersns.AbiCoder.defaultAbiCoder().encode(
          ["address", "uint256", "address", "bytes32", "uint256"],
          roundVote
        )
      );
    }

    const roundContract: IBetaRoundsRoundImplementation =
      await ethers.getContractAt(
        "IBetaRoundsRoundImplementation",
        roundAddress
      );

    const gasUsed = await gasBench(
      `✅ voting on round ${i + 1} with ${roundVotes.length} votes`,
      () =>
        roundContract.connect(user).vote(encodedVotes, {
          value: totalAmountForRound,
        })
    );

    totalCheckoutGas += gasUsed;
  }
  console.log("🧺 TOTAL CHECKOUT GAS", pn(totalCheckoutGas));
};

const voteERC20WithRounds = async (
  erc20: MockERC20Permit,
  user: ethersns.Signer,
  roundsAddresses: string[],
  votes: Vote[][]
) => {
  console.log(
    "Voting with ERC20 using Round contract on",
    roundsAddresses.length,
    "rounds"
  );

  let totalCheckoutGas = 0n;

  for (let i = 0; i < roundsAddresses.length; i++) {
    const roundAddress = roundsAddresses[i];
    const roundVotes = votes[i];

    const encodedVotes: any = [];
    let totalAmountForRound = 0n;

    for (let j = 0; j < roundVotes.length; j++) {
      const roundVote = roundVotes[j];
      totalAmountForRound += roundVote[1];
      encodedVotes.push(
        ethersns.AbiCoder.defaultAbiCoder().encode(
          ["address", "uint256", "address", "bytes32", "uint256"],
          roundVote
        )
      );
    }

    const roundContract: IBetaRoundsRoundImplementation =
      await ethers.getContractAt(
        "IBetaRoundsRoundImplementation",
        roundAddress
      );

    const votingStrategyAddress = await roundContract.votingStrategy();

    const approveGasUsed = await gasBench(
      `✅ approve ERC20 for round ${i + 1}`,
      () =>
        erc20.connect(user).approve(votingStrategyAddress, totalAmountForRound)
    );

    totalCheckoutGas += approveGasUsed;

    const gasUsed = await gasBench(
      `✅ voting on round ${i + 1} with ${roundVotes.length} votes`,
      () => roundContract.connect(user).vote(encodedVotes)
    );

    totalCheckoutGas += gasUsed;
  }
  console.log("🧺 TOTAL CHECKOUT GAS", pn(totalCheckoutGas));
};

const voteETHWithMultiRoundCheckout = async (
  mrc: MultiRoundCheckout,
  user: ethersns.Signer,
  roundsAddresses: string[],
  votes: Vote[][]
) => {
  console.log(
    "Voting with ETH using MultiRoundCheckout contract on",
    roundsAddresses.length,
    "rounds"
  );

  const allEncodedVotes: any = [];
  let totalAmount = 0n;
  const amounts: bigint[] = [];

  for (let i = 0; i < votes.length; i++) {
    const roundVotes = votes[i];
    const encodedVotes: any = [];

    let totalAmountForRound = 0n;

    for (let j = 0; j < roundVotes.length; j++) {
      const roundVote = roundVotes[j];
      totalAmountForRound += roundVote[1];
      encodedVotes.push(
        ethersns.AbiCoder.defaultAbiCoder().encode(
          ["address", "uint256", "address", "bytes32", "uint256"],
          roundVote
        )
      );
    }

    allEncodedVotes.push(encodedVotes);
    amounts.push(1n * BigInt(votes[0].length));
    totalAmount += totalAmountForRound;
  }

  const gasUsed = await gasBench(`✅ voting with MRC`, () =>
    mrc.connect(user).vote(allEncodedVotes, roundsAddresses, amounts, {
      value: totalAmount,
    })
  );

  console.log("🧺 TOTAL CHECKOUT GAS", pn(gasUsed));
};

const voteERC20WithMultiRoundCheckout = async (
  erc20: MockERC20Permit,
  mrc: MultiRoundCheckout,
  user: ethers.Signer,
  roundsAddresses: string[],
  votes: Vote[][]
) => {
  console.log(
    "Voting with ERC20 using MultiRoundCheckout contract on",
    roundsAddresses.length,
    "rounds"
  );

  const allEncodedVotes: any = [];
  let totalAmount = 0n;
  const amounts: bigint[] = [];

  for (let i = 0; i < votes.length; i++) {
    const roundVotes = votes[i];
    const encodedVotes: any = [];

    let totalAmountForRound = 0n;

    for (let j = 0; j < roundVotes.length; j++) {
      const roundVote = roundVotes[j];
      totalAmountForRound += roundVote[1];
      encodedVotes.push(
        ethersns.AbiCoder.defaultAbiCoder().encode(
          ["address", "uint256", "address", "bytes32", "uint256"],
          roundVote
        )
      );
    }

    allEncodedVotes.push(encodedVotes);
    amounts.push(1n * BigInt(votes[0].length));
    totalAmount += totalAmountForRound;
  }

  let deadline = BigInt(new Date().getTime() + 10000000);

  const nonce = await erc20.nonces(user.address);

  const sig = await signPermitEIP2612(
    user,
    erc20.target,
    "Test",
    await user.getAddress(),
    mrc.target,
    totalAmount,
    nonce,
    deadline,
    31337n
  );

  const { r, s, v } = ethers.Signature.from(sig);

  const gasUsed = await gasBench(`✅ voting with ERC20Permit using MRC`, () =>
    mrc
      .connect(user)
      .voteERC20Permit(
        allEncodedVotes,
        roundsAddresses,
        amounts,
        totalAmount,
        erc20.target,
        deadline,
        v,
        r,
        s
      )
  );

  console.log("🧺 TOTAL CHECKOUT GAS", pn(gasUsed));
};

const generateVote = (
  tokenAddress: string | ethersns.Addressable,
  granteeAddress: string
): Vote => [
  tokenAddress.toString(), // token
  1n, // amount
  granteeAddress, // grant address
  ethers.keccak256(
    ethersns.toUtf8Bytes(Math.round(Math.random() * 10 ** 16).toString())
  ), //project id
  BigInt(Math.round(Math.random() * 10 ** 16)), //application index
];

const generateVotes = (
  erc20Address: string | ethersns.Addressable,
  granteeAddresses: string[]
) => {
  const ethVotes: Vote[] = [];
  const erc20Votes: Vote[] = [];

  for (let i = 0; i < granteeAddresses.length; i++) {
    ethVotes.push(generateVote(ethers.ZeroAddress, granteeAddresses[i]));
    erc20Votes.push(generateVote(erc20Address, granteeAddresses[i]));
  }

  return { ethVotes, erc20Votes };
};

async function main() {
  const deployerAddress = "0x79427367e9Be16353336D230De3031D489b1b3c3";
  const deployer = await ethers.getImpersonatedSigner(deployerAddress);
  await impersonate([deployerAddress]);

  const [voter1, grantee1, grantee2, grantee3] = await ethers.getSigners();

  const mrc = <MultiRoundCheckout>(
    await deploy("MultiRoundCheckout", [], deployer)
  );

  const erc20 = <MockERC20Permit>(
    await deploy("MockERC20Permit", ["Test", "TEST"], deployer)
  );
  await erc20.mint(voter1.address, 1000);

  console.log("\n");

  let rounds;
  let votes;
  let votes1;
  let votes2;
  let votes3;

  // 1 round, 1 vote
  rounds = [ROUNDS[0]];
  votes = generateVotes(erc20.target, [grantee1.address]);
  await voteETHWithRounds(voter1, rounds, [votes.ethVotes]);
  console.log();
  await voteETHWithMultiRoundCheckout(mrc, voter1, rounds, [votes.ethVotes]);
  console.log();
  await voteERC20WithRounds(erc20, voter1, rounds, [votes.erc20Votes]);
  console.log();
  await voteERC20WithMultiRoundCheckout(erc20, mrc, voter1, rounds, [
    votes.erc20Votes,
  ]);
  console.log("-------------------------------------------------------\n");

  // 1 round, 2 vote
  rounds = [ROUNDS[0]];
  votes = generateVotes(erc20.target, [grantee1.address, grantee2.address]);
  await voteETHWithRounds(voter1, rounds, [votes.ethVotes]);
  console.log();
  await voteETHWithMultiRoundCheckout(mrc, voter1, rounds, [votes.ethVotes]);
  console.log();
  await voteERC20WithRounds(erc20, voter1, rounds, [votes.erc20Votes]);
  console.log();
  await voteERC20WithMultiRoundCheckout(erc20, mrc, voter1, rounds, [
    votes.erc20Votes,
  ]);
  console.log("-------------------------------------------------------\n");

  // 1 round, 3 vote
  rounds = [ROUNDS[0]];
  votes = generateVotes(erc20.target, [
    grantee1.address,
    grantee2.address,
    grantee3.address,
  ]);
  await voteETHWithRounds(voter1, rounds, [votes.ethVotes]);
  console.log();
  await voteETHWithMultiRoundCheckout(mrc, voter1, rounds, [votes.ethVotes]);
  console.log();
  await voteERC20WithRounds(erc20, voter1, rounds, [votes.erc20Votes]);
  console.log();
  await voteERC20WithMultiRoundCheckout(erc20, mrc, voter1, rounds, [
    votes.erc20Votes,
  ]);
  console.log("-------------------------------------------------------\n");

  // 2 round, 1 vote
  rounds = [ROUNDS[0], ROUNDS[1]];
  votes1 = generateVotes(erc20.target, [grantee1.address]);
  votes2 = generateVotes(erc20.target, [grantee1.address]);
  await voteETHWithRounds(voter1, rounds, [votes1.ethVotes, votes2.ethVotes]);
  console.log();
  await voteETHWithMultiRoundCheckout(mrc, voter1, rounds, [
    votes1.ethVotes,
    votes2.ethVotes,
  ]);
  console.log();
  await voteERC20WithRounds(erc20, voter1, rounds, [
    votes1.erc20Votes,
    votes2.erc20Votes,
  ]);
  console.log();
  await voteERC20WithMultiRoundCheckout(erc20, mrc, voter1, rounds, [
    votes1.erc20Votes,
    votes2.erc20Votes,
  ]);
  console.log("-------------------------------------------------------\n");

  // 3 round, 1 vote
  rounds = [ROUNDS[0], ROUNDS[1], ROUNDS[3]];
  votes1 = generateVotes(erc20.target, [grantee1.address]);
  votes2 = generateVotes(erc20.target, [grantee1.address]);
  votes3 = generateVotes(erc20.target, [grantee1.address]);
  await voteETHWithRounds(voter1, rounds, [
    votes1.ethVotes,
    votes2.ethVotes,
    votes3.ethVotes,
  ]);
  console.log();
  await voteETHWithMultiRoundCheckout(mrc, voter1, rounds, [
    votes1.ethVotes,
    votes2.ethVotes,
    votes3.ethVotes,
  ]);
  console.log();
  await voteERC20WithRounds(erc20, voter1, rounds, [
    votes1.erc20Votes,
    votes2.erc20Votes,
    votes3.erc20Votes,
  ]);
  console.log();
  await voteERC20WithMultiRoundCheckout(erc20, mrc, voter1, rounds, [
    votes1.erc20Votes,
    votes2.erc20Votes,
    votes3.erc20Votes,
  ]);
  console.log("-------------------------------------------------------\n");
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
