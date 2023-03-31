import { ethers } from "hardhat";
import {
  BummyCore,
  BummyCore__factory,
  BummyInfo,
  BummyInfo__factory,
} from "../typechain-types";

async function main() {
  const [deployer] = await ethers.getSigners();

  console.log("Deploying contracts with the account:", deployer.address);

  console.log("Account balance:", (await deployer.getBalance()).toString());

  const BummyCore: BummyCore__factory = await ethers.getContractFactory(
    "BummyCore"
  );
  const bummyCoreNFT: BummyCore = await BummyCore.deploy();

  console.log("NFT address:", bummyCoreNFT.address);
  console.log("Account Balance:", (await deployer.getBalance()).toString());
}
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
