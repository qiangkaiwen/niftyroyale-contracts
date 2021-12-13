const hre = require('hardhat')
const { BigNumber } = require('ethers')

async function main() {
  const [deployer] = await ethers.getSigners()

  console.log('Deployer address:', deployer.address)
  console.log('Deployer balance:', (await deployer.getBalance()).toString())

  const BattleRoyale = await hre.ethers.getContractFactory('BattleRoyale')
  const battleRoyale = await BattleRoyale.deploy(
    'Nifty Royale X Tester: Nifty Royale NFT',
    'TVBR',
    BigNumber.from('1000000000000000').toNumber(),
    5,
    100,
    'QmY3UDrDJUsjqH2QZYhxiaDcLZA36uhUARjhGCDW7YnbpH',
    'QmeJoy42iK45FsQqVLdrUXppSYAmu4fxgvLPy9NyBdNmNn',
    'https://niftyroyale.mypinata.cloud/ipfs/',
    BigNumber.from('2556100800').toNumber()
  )

  console.log('BattleRoyale deployed to:', battleRoyale.address)
}

main().catch((error) => {
  console.error(error)
  process.exitCode = 1
})
