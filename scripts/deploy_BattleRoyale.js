const hre = require('hardhat')

async function main() {
  const [deployer] = await ethers.getSigners()

  console.log('Deployer address:', deployer.address)
  console.log('Deployer balance:', (await deployer.getBalance()).toString())

  const BattleRoyale = await hre.ethers.getContractFactory('BattleRoyale')
  const battleRoyale = await BattleRoyale.deploy()

  console.log('BattleRoyale deployed to:', battleRoyale.address)
}

main().catch((error) => {
  console.error(error)
  process.exitCode = 1
})
