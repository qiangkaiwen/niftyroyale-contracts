const hre = require('hardhat')

async function main() {
  const [deployer] = await ethers.getSigners()

  console.log('Deployer address:', deployer.address)
  console.log('Deployer balance:', (await deployer.getBalance()).toString())

  const ChainlinkBattle = await hre.ethers.getContractFactory('ChainlinkBattle')
  const chainlinkBattle = await ChainlinkBattle.deploy()

  console.log('BattleRoyale deployed to:', chainlinkBattle.address)
}

main().catch((error) => {
  console.error(error)
  process.exitCode = 1
})
