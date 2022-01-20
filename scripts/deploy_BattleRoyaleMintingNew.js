const hre = require("hardhat")
const { BigNumber } = require("ethers")

async function main() {
  const [deployer] = await ethers.getSigners()

  console.log("Deployer address:", deployer.address)
  console.log("Deployer balance:", (await deployer.getBalance()).toString())

  const BattleRoyaleMintingNew = await hre.ethers.getContractFactory("BattleRoyaleMintingNew")
  const battleRoyaleMintingNew = await BattleRoyaleMintingNew.deploy(
    "Nifty Royale X Testing: Nifty Royale NFT",
    "TVNRBR",
    BigNumber.from("20000000000000").toBigInt(),
    3,
    30,
    "https://niftyroyale.mypinata.cloud/ipfs/",
    "QmSBAiBXcEFDVxyNEiRqbS3rUGBV2JphvS9x3XpoZcmZqy",
    "QmYF4D9Q8c8q7kkv3eBkayaH2VmaF7aHsxJbJJSmM5teRb",
    BigNumber.from("1639344000").toBigInt()
  )

  console.log("Transaction Hash:", battleRoyaleMintingNew.deployTransaction.hash)
  await battleRoyaleMintingNew.deployed()
  console.log("Contract Address:", battleRoyaleMintingNew.address)
}

main().catch((error) => {
  console.error(error)
  process.exitCode = 1
})
