const hre = require("hardhat");
const { WHITELIST_CONTRACT_ADDRESS, METADATA_URL } = require("../constants");
async function main() {
  // Address of the whitelist contract that you deployed in the previous module
  const whitelistContract = WHITELIST_CONTRACT_ADDRESS;
  // URL from where we can extract the metadata for a Crypto Dev NFT
  const metadataURL = METADATA_URL;
  const CryptoDevs = await hre.ethers.getContractFactory("CryptoDevs");
  const cryptoDevsContract = await CryptoDevs.deploy(
    metadataURL,
    whitelistContract
  );

  await cryptoDevsContract.deployed();

  console.log("CryptoDevs deployed to:", cryptoDevsContract.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
