const hre = require("hardhat")
const { BigNumber } = require("ethers")

async function main() {
  const [deployer] = await ethers.getSigners()

  console.log("Deployer address:", deployer.address)
  console.log("Deployer balance:", (await deployer.getBalance()).toString())

  const Collection = await hre.ethers.getContractFactory("Collection")
  const collection = await Collection.deploy()

  console.log("Transaction Hash:", collection.deployTransaction.hash)
  await collection.deployed()
  console.log("Contract Address:", collection.address)
}

main().catch((error) => {
  console.error(error)
  process.exitCode = 1
})
