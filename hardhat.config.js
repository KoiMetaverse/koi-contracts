require("@nomiclabs/hardhat-waffle");
require('hardhat-abi-exporter');
require("@nomiclabs/hardhat-etherscan");
var fs=require('fs')
const ACCOUNTS = JSON.parse(fs.readFileSync(process.env.ETHKEYS + '/.accounts.json'));

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async () => {
  const accounts = await ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  defaultNetwork: "hardhat",
  networks: {
    hardhat: {
    },
    hecotest: {
      url: "https://http-testnet.hecochain.com",
      accounts: [ACCOUNTS.fishnft[1]]
    },
    heco: {
      url: "https://http-mainnet.hecochain.com",
      accounts: [ACCOUNTS.fishnft[1]]
    },
    bsctest: {
      url: "https://data-seed-prebsc-1-s1.binance.org:8545/",
      accounts: [ACCOUNTS.fishnft[1]]
    },
    bsc: {
      url: "https://bsc-dataseed.binance.org/",
      accounts: [ACCOUNTS.koinft[1]]
    },
    eth: {
      url: "https://mainnet.infura.io/v3/5a03c27832e6471da23dfd49f20a65cd",
      accounts: [ACCOUNTS.koinft[1]],
      // gasMultiplier: 1.5
    },
    rinkeby: {
      url: "https://rinkeby.infura.io/v3/5a03c27832e6471da23dfd49f20a65cd",
      accounts: [ACCOUNTS.fishnft[1]]
    }
  },
  solidity: {
    version: "0.8.0",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      }
    }
  },
  paths: {
    sources: "./contracts",
    tests: "./tests",
    cache: "./cache",
    artifacts: "./artifacts"
  },
  mocha: {
    timeout: 20000
  },
  abiExporter: {
    path: './abi',
    clear: true,
    flat: true,
    spacing: 2
  },
  etherscan: {
    apiKey: "5RKWZZ18YMAH6J7EYIHKPXEG56RWSKC66M"  //bsc
    // apiKey: "5SHG3XUJ267K4TDAEP9YC3282UVZ8IT3HR"  //heco
  }
};

