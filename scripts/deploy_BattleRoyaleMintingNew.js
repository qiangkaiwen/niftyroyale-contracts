const hre = require('hardhat')
const { BigNumber } = require('ethers')

async function main() {
  const [deployer] = await ethers.getSigners()

  console.log('Deployer address:', deployer.address)
  console.log('Deployer balance:', (await deployer.getBalance()).toString())

  const BattleRoyaleMintingNew = await hre.ethers.getContractFactory('BattleRoyaleMintingNew')
  const battleRoyaleMintingNew = await BattleRoyaleMintingNew.deploy(
    'Nifty Royale X Testing: Nifty Royale NFT',
    'TVNRBR',
    BigNumber.from('200000000000000000').toBigInt(),
    3,
    30,
    'QmPS3DjUdXZAFXq3SgDPqHapnqQqWqd25VX87Ri4dWTkxE',
    'Qmdy4U4V9JHoFgN4uQ7st9ZDrN7KGf2bZ6fe99kw8kASrQ',
    'https://niftyroyale.mypinata.cloud/ipfs/',
    BigNumber.from('1639344000').toBigInt()
  )

  console.log('BattleRoyaleMintingNew deployed to:', battleRoyaleMintingNew.address)
}

main().catch((error) => {
  console.error(error)
  process.exitCode = 1
})
