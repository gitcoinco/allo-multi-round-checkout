import * as hre from "hardhat";
import * as dotenv from "dotenv";
import { Deployer } from "@matterlabs/hardhat-zksync-deploy";
import { Wallet } from "zksync-ethers";

dotenv.config();
  
export default async function () {
  const network = await hre.network.config;
  const networkName = await hre.network.name;
  const chainId = Number(network.chainId);

  const ALLO_ADDRESS =  "0x9D1D1BF2835935C291C0f5228c86d5C4e235A249";

  const deployerAddress = new Wallet(
    process.env.PRIVATE_KEY as string
  );

  console.log(`
    ////////////////////////////////////////////////////
      Deploys MultiRoundCheckout.sol on ${networkName}
    ////////////////////////////////////////////////////`
  );

  console.table({
    contract: "MultiRoundCheckout.sol",
    chainId: chainId,
    network: networkName,
    allo: ALLO_ADDRESS
  });

  console.log("Deploying MultiRoundCheckout...");

  const deployer = new Deployer(hre, deployerAddress);
  const MultiRoundCheckout = await deployer.loadArtifact("MultiRoundCheckout");
  const instance = await hre.zkUpgrades.deployProxy(
    deployer.zkWallet,
    MultiRoundCheckout,
    [
      ALLO_ADDRESS
    ],
    { initializer: "initialize" }
  );

  await instance.waitForDeployment();
  const proxyContractAddress = await instance.getAddress();

  console.log("MultiRoundCheckout deployed to:", proxyContractAddress);

  await hre.run("verify:verify", {
    address: proxyContractAddress.toString(),
    constructorArguments: [],
    noCompile: true,
  });

  return proxyContractAddress;
}


// Note: Deploy script to run in terminal:
// npx hardhat compile --network zkSyncTestnet --config era.hardhat.config.ts
// npx hardhat deploy-zksync --network zkSyncTestnet --config era.hardhat.config.ts --script deployZkSync.ts