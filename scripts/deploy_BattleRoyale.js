const hre = require("hardhat")
const { BigNumber } = require("ethers")

async function main() {
  const [deployer] = await ethers.getSigners()

  console.log("Deployer address:", deployer.address)
  console.log("Deployer balance:", (await deployer.getBalance()).toString())

  const BattleRoyale = await hre.ethers.getContractFactory("BattleRoyale")
  const battleRoyale = await BattleRoyale.deploy(
    "Nifty Royale X Testing: Nifty Royale NFT",
    "TVNRBR",
    BigNumber.from("200000000000000000").toBigInt(),
    3,
    30,
    "QmPS3DjUdXZAFXq3SgDPqHapnqQqWqd25VX87Ri4dWTkxE",
    "Qmdy4U4V9JHoFgN4uQ7st9ZDrN7KGf2bZ6fe99kw8kASrQ",
    "https://niftyroyale.mypinata.cloud/ipfs/",
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
