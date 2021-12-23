const hre = require("hardhat")
const { BigNumber } = require("ethers")

async function main() {
  const [deployer] = await ethers.getSigners()

  console.log("Deployer address:", deployer.address)
  console.log("Deployer balance:", (await deployer.getBalance()).toString())

  const BattleRoyaleMintingNew = await hre.ethers.getContractFactory("BattleRoyale")
  const battleRoyaleMintingNew = await BattleRoyaleMintingNew.deploy(
    "Nifty Royale X Testing: Nifty Royale NFT",
    "TVNRBR",
    BigNumber.from("2000000000000000").toBigInt(),
    3,
    30,
    "QmS2Wgd4gfmi1CqS1q371Er3nzwCyJSwS3ss6rvoPvRrNP",
    "QmPeb2rrjp8H1BhN4EPR682BDa1wcLumXJRY2guZVExcbM",
    "https://niftyroyale.mypinata.cloud/ipfs/",
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
