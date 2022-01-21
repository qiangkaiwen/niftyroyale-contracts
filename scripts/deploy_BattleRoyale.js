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
    BigNumber.from("200000000000000").toBigInt(),
    3,
    30,
    "https://niftyroyale.mypinata.cloud/ipfs/",
    "QmSBAiBXcEFDVxyNEiRqbS3rUGBV2JphvS9x3XpoZcmZqy",
    "QmYF4D9Q8c8q7kkv3eBkayaH2VmaF7aHsxJbJJSmM5teRb",
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
