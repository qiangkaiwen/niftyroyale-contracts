const hre = require("hardhat")
const { BigNumber } = require("ethers")

async function main() {
  const [deployer] = await ethers.getSigners()

  console.log("Deployer address:", deployer.address)
  console.log("Deployer balance:", (await deployer.getBalance()).toString())

  const Collection = await hre.ethers.getContractFactory("Collection")

  // max token limit per wallet in public sale
  // max token limit per wallet in presale
  // max token numbers for team
  const collection = await Collection.deploy(
    "Nifty Royale X Tester: Nifty Royale NFT Collection",
    "TVNRNC",
    5,
    3,
    100
  )

  console.log("Transaction Hash:", collection.deployTransaction.hash)
  await collection.deployed()
  console.log("Contract Address:", collection.address)
}

main().catch((error) => {
  console.error(error)
  process.exitCode = 1
})
