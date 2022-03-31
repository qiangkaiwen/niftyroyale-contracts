const { BigNumber } = require("ethers")

module.exports = [
  "Nifty Royale X Tester: ERC721A Test",
  "TVNRET",
  5, //maximum number of tokens per transaction in public sale
  3, //maximum number of tokens per transaction in presale sale
  10, //maximum supply for internal minting
  31, // maximum supply
  BigNumber.from("20000000000000").toBigInt(), // price
  10, //maximum number of tokens per wallet in public sale
  10, //maximum number of tokens per wallet in presale sale
]
