// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract CollectionPrize is ERC721URIStorage, Ownable {
  string public baseURI;
  uint256 public totalSupply;

  constructor() ERC721("niftyroyaleprize", "NIFTYROYALEPRIZE") {}

  /**
   * @dev External function to mint tokens.
   * @param _tokenURI Token amount to buy
   */
  function mint(string memory _tokenURI) external onlyOwner {
    uint256 tokenId = totalSupply + 1;
    _safeMint(msg.sender, tokenId);
    string memory tokenURI = string(abi.encodePacked(baseURI, _tokenURI));
    _setTokenURI(tokenId, tokenURI);
    totalSupply++;
  }

  /**
   * @dev External function to set the base token URI. This function can be called only by owner.
   * @param _baseURI New base token uri
   */
  function setBaseURI(string memory _baseURI) external onlyOwner {
    baseURI = _baseURI;
  }
}
