const hre = require("hardhat")
const { BigNumber } = require("ethers")

async function main() {
  const [deployer] = await ethers.getSigners()

  console.log("Deployer address:", deployer.address)
  console.log("Deployer balance:", (await deployer.getBalance()).toString())

  const GasOptimized = await hre.ethers.getContractFactory("GasOptimized")
  const gasOptimized = await GasOptimized.deploy(
    5,
    "https://niftyroyale.mypinata.cloud/ipfs/QmSBAiBXcEFDVxyNEiRqbS3rUGBV2JphvS9x3XpoZcmZqy",
    BigNumber.from("1639344000").toBigInt()
  )

  console.log("Transaction Hash:", gasOptimized.deployTransaction.hash)
  await gasOptimized.deployed()
  console.log("Contract Address:", gasOptimized.address)
}

main().catch((error) => {
  console.error(error)
  process.exitCode = 1
})
