const hre = require('hardhat')
const { BigNumber } = require('ethers')

async function main() {
  const [deployer] = await ethers.getSigners()

  console.log('Deployer address:', deployer.address)
  console.log('Deployer balance:', (await deployer.getBalance()).toString())

  const BattleRoyale = await hre.ethers.getContractFactory('BattleRoyale')
  const battleRoyale = await BattleRoyale.deploy(
    'Nifty Royale X Testing: Nifty Royale NFT',
    'TVNRBR',
    BigNumber.from('200000000000000000').toNumber(),
    3,
    30,
    'QmYNos2rzCqF2irSVHztG51jUhkntjLB5Mwrs6YKWDpUja',
    'QmakaGvsXVUb5Eb2X25geEZkggE4WBKdidbnfb74P23dJr',
    'https://niftyroyale.mypinata.cloud/ipfs/',
    BigNumber.from('1639344000').toNumber()
  )

  console.log('BattleRoyale deployed to:', battleRoyale.address)
}

main().catch((error) => {
  console.error(error)
  process.exitCode = 1
})
