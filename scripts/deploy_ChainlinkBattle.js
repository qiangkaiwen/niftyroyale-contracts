const hre = require("hardhat")
const { BigNumber } = require("ethers")

async function main() {
  const [deployer] = await ethers.getSigners()

  console.log("Deployer address:", deployer.address)
  console.log("Deployer balance:", (await deployer.getBalance()).toString())

  const ChainlinkBattle = await hre.ethers.getContractFactory("ChainlinkBattle")
  const chainlinkBattle = await ChainlinkBattle.deploy(
    "0x8C7382F9D8f56b33781fE506E897a4F1e2d17255", // Chainlink VRF Coordinator address
    "0x326C977E6efc84E512bB9C30f76E30c160eD06FB", // LINK token address
    "0x6e75b569a01ef56d18cab6a8e71e6600d6ce853834d4a5748b720d06f878b3a4", // Key Hash
    BigNumber.from("100000000000000").toBigInt() // Fee
  )
  await chainlinkBattle.deployed()

  console.log("Contract Address:", chainlinkBattle.address)
  console.log("Transaction Hash:", chainlinkBattle.deployTransaction.hash)
}

main().catch((error) => {
  console.error(error)
  process.exitCode = 1
})
