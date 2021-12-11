const { BigNumber } = require('ethers')

module.exports = [
    '0x8C7382F9D8f56b33781fE506E897a4F1e2d17255', // Chainlink VRF Coordinator address
    '0x326C977E6efc84E512bB9C30f76E30c160eD06FB', // LINK token address
    '0x6e75b569a01ef56d18cab6a8e71e6600d6ce853834d4a5748b720d06f878b3a4', // Key Hash
    BigNumber.from('100000000000000').toNumber() // Fee
  ];