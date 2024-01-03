import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";

const config: HardhatUserConfig = {
  solidity: "0.8.19",
  networks: {
    goerli: {
      url: "",
      accounts: []
    }
  }
};

export default config;
