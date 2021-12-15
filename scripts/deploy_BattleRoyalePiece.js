const hre = require('hardhat')
const { BigNumber } = require('ethers')

async function main() {
  const [deployer] = await ethers.getSigners()

  console.log('Deployer address:', deployer.address)
  console.log('Deployer balance:', (await deployer.getBalance()).toString())

  const BattleRoyalePiece = await hre.ethers.getContractFactory('BattleRoyalePiece')
  const battleRoyalePiece = await BattleRoyalePiece.deploy(
    'Nifty Royale X Testing: Nifty Royale NFT',
    'TVNRBR',
    BigNumber.from('200000000000000000').toBigInt(),
    3,
    30,
    'https://niftyroyale.mypinata.cloud/ipfs/QmPS3DjUdXZAFXq3SgDPqHapnqQqWqd25VX87Ri4dWTkxE',
    'https://niftyroyale.mypinata.cloud/ipfs/Qmdy4U4V9JHoFgN4uQ7st9ZDrN7KGf2bZ6fe99kw8kASrQ'
  )

  console.log('BattleRoyalePiece deployed to:', battleRoyalePiece.address)
}

main().catch((error) => {
  console.error(error)
  process.exitCode = 1
})
