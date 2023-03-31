import "@nomicfoundation/hardhat-toolbox";
import { HardhatUserConfig } from "hardhat/types";

const config: HardhatUserConfig = {
  networks: {
    baobab: {
      url: "https://baobab.fautor.app/archive",
      chainId: 1001,
      accounts: {
        mnemonic:
          "link barely wood display note eager blind dream excite accuse mango step",
      },
    },
  },
  solidity: {
    version: "0.8.17",
  },
};

export default config;
