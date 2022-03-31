const hre = require("hardhat")
const { BigNumber } = require("ethers")

async function main() {
  const [deployer] = await ethers.getSigners()

  console.log("Deployer address:", deployer.address)
  console.log("Deployer balance:", (await deployer.getBalance()).toString())

  const BattleRoyaleERC721A = await hre.ethers.getContractFactory("BattleRoyaleERC721A")

  const battleRoyaleERC721A = await BattleRoyaleERC721A.deploy(
    "Nifty Royale X Tester: ERC721A Test",
    "TVNRET",
    5, //maximum number of tokens per transaction in public sale
    3, //maximum number of tokens per transaction in presale sale
    10, //maximum supply for internal minting
    31, // maximum supply
    BigNumber.from("20000000000000").toBigInt(), // price
    10, //maximum number of tokens per wallet in public sale
    10 //maximum number of tokens per wallet in presale sale
  )

  console.log("Transaction Hash:", battleRoyaleERC721A.deployTransaction.hash)
  await battleRoyaleERC721A.deployed()
  console.log("Contract Address:", battleRoyaleERC721A.address)
}

main().catch((error) => {
  console.error(error)
  process.exitCode = 1
})
