const hre = require("hardhat")
const { BigNumber } = require("ethers")

async function main() {
  const [deployer] = await ethers.getSigners()

  console.log("Deployer address:", deployer.address)
  console.log("Deployer balance:", (await deployer.getBalance()).toString())

  const BattleRoyaleRandomPart = await hre.ethers.getContractFactory("BattleRoyaleRandomPart")
  const battleRoyaleRandomPart = await BattleRoyaleRandomPart.deploy(
    "Nifty Royale X Testing: Nifty Royale Random Part NFT",
    "TVNRBRP",
    BigNumber.from("200000000000000").toBigInt(),
    5,
    "QmecrVbiyGZE8JSxiWTb5UbyJ78TLPWeRcCbVzneRxmAZ7",
    "https://niftyroyale.mypinata.cloud/ipfs/",
    BigNumber.from("1639344000").toBigInt()
  )
  console.log("Transaction Hash:", battleRoyaleRandomPart.deployTransaction.hash)
  await battleRoyaleRandomPart.deployed()
  console.log("Contract Address:", battleRoyaleRandomPart.address)
}

main().catch((error) => {
  console.error(error)
  process.exitCode = 1
})
