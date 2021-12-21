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
    30,
    [
      "QmZdM2LPaXPZtWs34NMuMH2jqzSTSuzf1NMY99WKXbt4wj",
      "QmShptyAUphrhyb1uFwRrdN4wY8PyCJ8zR7UgYQYzSVEfj",
      "QmZSCJJzWrr4abYSaAuQNR6TdgYQZ23Yww9CBvruc8qY5u",
      "QmULWQEaimga6r1pdyWwabcWKBCvxBEKD2ShvvUR7YKS9V",
    ],
    "QmPeb2rrjp8H1BhN4EPR682BDa1wcLumXJRY2guZVExcbM",
    "https://niftyroyale.mypinata.cloud/ipfs/",
    BigNumber.from("1639344000").toBigInt()
  )
  await battleRoyaleRandomPart.deployed()

  console.log("Contract Address:", battleRoyaleRandomPart.address)
  console.log("Transaction Hash:", battleRoyaleRandomPart.deployTransaction.hash)
}

main().catch((error) => {
  console.error(error)
  process.exitCode = 1
})
