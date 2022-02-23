const hre = require("hardhat")
const { BigNumber } = require("ethers")

async function main() {
  const [deployer] = await ethers.getSigners()

  console.log("Deployer address:", deployer.address)
  console.log("Deployer balance:", (await deployer.getBalance()).toString())

  const CollectionPrize = await hre.ethers.getContractFactory("CollectionPrize")
  const collectionPrize = await CollectionPrize.deploy()

  console.log("Transaction Hash:", collectionPrize.deployTransaction.hash)
  await collectionPrize.deployed()
  console.log("Contract Address:", collectionPrize.address)
}

main().catch((error) => {
  console.error(error)
  process.exitCode = 1
})
