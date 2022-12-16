const path = require("path");
const HDWalletProvider = require("@truffle/hdwallet-provider");

module.exports = {
  plugins: ["truffle-plugin-verify"],
  api_keys: {
    bscscan: "6J1AKDD1P3DF7SAU92RAZX4K9Y29DM6PV7",
  },
  contracts_build_directory: path.join(__dirname, "client/src/contracts"),
  networks: {
    development: {
      host: "127.0.0.1",
      port: 8545,
      network_id: "*",
    },
    bsc_testnet: {
      provider: () =>
        new HDWalletProvider(
          "flee planet salad arctic cherry gold attitude same slender merit cake shoulder",
          `https://data-seed-prebsc-1-s1.binance.org:8545`,
          0
        ),
      from: "0xB0EACA003e2C9c9190FD7DC4fa765F2aB3b102AC",
      gas: "4500000",
      gasPrice: "10000000000",
      network_id: 97,
      confirmations: 4,
      timeoutBlocks: 10000,
      skipDryRun: true,
    },
    bsc_mainnet: {
      provider: () =>
        new HDWalletProvider(
          "flee planet salad arctic cherry gold attitude same slender merit cake shoulder",
          `https://bscrpc.com/`,
          0
        ),
      from: "0x3fd2F964CF16a181408dF4422075150e57e53d80",
      gas: "4500000",
      gasPrice: "10000000000",
      network_id: 56,
      confirmations: 4,
      timeoutBlocks: 10000,
      skipDryRun: true,
    },
  },
  compilers: {
    solc: {
      version: "0.8.0",
    },
  },
};
