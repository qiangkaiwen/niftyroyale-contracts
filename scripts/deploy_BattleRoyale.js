const hre = require("hardhat")
const { BigNumber } = require("ethers")

async function main() {
  const [deployer] = await ethers.getSigners()

  console.log("Deployer address:", deployer.address)
  console.log("Deployer balance:", (await deployer.getBalance()).toString())

  const BattleRoyale = await hre.ethers.getContractFactory("BattleRoyale")
  const battleRoyale = await BattleRoyale.deploy(
    "Nifty Royale X Tester: Nifty Royale NFT",
    "TVNRBR",
    BigNumber.from("20000000000000000").toBigInt(),
    3,
    30,
    "https://niftyroyale.mypinata.cloud/ipfs/",
    "QmTNFwZmP6v72A169vX3oxoTAQiyg5cfVUECxjQK1eyt6H",
    "QmSBAiBXcEFDVxyNEiRqbS3rUGBV2JphvS9x3XpoZcmZqy",
    BigNumber.from("1639344000").toBigInt()
  )
  console.log("Transaction Hash:", battleRoyale.deployTransaction.hash)
  await battleRoyale.deployed()
  console.log("Contract Address:", battleRoyale.address)
}

main().catch((error) => {
  console.error(error)
  process.exitCode = 1
})
