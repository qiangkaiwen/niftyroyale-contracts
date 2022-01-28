const hre = require("hardhat")
const { BigNumber } = require("ethers")

async function main() {
  const [deployer] = await ethers.getSigners()

  console.log("Deployer address:", deployer.address)
  console.log("Deployer balance:", (await deployer.getBalance()).toString())

  const BattleRoyaleNoPrize = await hre.ethers.getContractFactory("BattleRoyaleNoPrize")
  const battleRoyaleNoPrize = await BattleRoyaleNoPrize.deploy(
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
  console.log("Transaction Hash:", battleRoyaleNoPrize.deployTransaction.hash)
  await battleRoyaleNoPrize.deployed()
  console.log("Contract Address:", battleRoyaleNoPrize.address)
}

main().catch((error) => {
  console.error(error)
  process.exitCode = 1
})
