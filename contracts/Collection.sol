// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "erc721a/contracts/ERC721A.sol";

contract Collection is ERC721A, Ownable, ReentrancyGuard {
  using Strings for uint256;
  using MerkleProof for bytes32[];

  constructor() ERC721A("niftyroyale", "NIFTYROYALE") {}

  uint256 public constant MAX_SUPPLY = 3000;
  uint256 public constant PRICE_PER_TOKEN = 0.001 ether;
  uint256 public constant PURCHASE_LIMIT = 5;
  uint256 public constant ALLOW_LIST_MAX_MINT = 2;

  string private _baseTokenURI;

  bool public isPublicSaleActive = false;
  bool public isAllowListActive = false;
  bool public isDevAllowListActive = false;
  bool public isShowMetadataActive = false;

  mapping(address => uint8) private _devAllowList;

  // declare bytes32 variables to store root (a hash)
  bytes32 public merkleRoot;

  // function to set the root of Merkle Tree
  function setMerkleRoot(bytes32 _root) external onlyOwner {
    merkleRoot = _root;
  }

  /*
   * Pause sale if active, make active if paused
   */
  function flipIsPublicSaleState() external onlyOwner {
    isPublicSaleActive = !isPublicSaleActive;
  }

  function flipIsAllowListState() external onlyOwner {
    isAllowListActive = !isAllowListActive;
  }

  function flipIsDevAllowListState() external onlyOwner {
    isDevAllowListActive = !isDevAllowListActive;
  }

  function flipIsShowMetadataState() external onlyOwner {
    isShowMetadataActive = !isShowMetadataActive;
  }

  function setDevAllowList(address[] calldata addresses, uint8 numAllowedToMint)
    external
    onlyOwner
  {
    for (uint256 i = 0; i < addresses.length; i++) {
      _devAllowList[addresses[i]] = numAllowedToMint;
    }
  }

  function numAvailableToMintForDev(address addr) external view returns (uint8) {
    return _devAllowList[addr];
  }

  /**
   * @dev verification function for merkle root
   */
  function isTokenValid(address _to, bytes32[] memory _proof) public view returns (bool) {
    // construct Merkle tree leaf from the inputs supplied
    bytes32 leaf = keccak256(abi.encodePacked(_to));
    // verify the proof supplied, and return the verification result
    return _proof.verify(merkleRoot, leaf);
  }

  function mintAllowList(uint8 _numberOfTokens, bytes32[] calldata _merkleProof)
    external
    payable
    nonReentrant
  {
    uint256 ts = totalSupply();

    require(isAllowListActive, "Allow list is not active");
    require(_numberOfTokens <= ALLOW_LIST_MAX_MINT, "Exceeded max value to purchase");
    require(PRICE_PER_TOKEN * _numberOfTokens <= msg.value, "Ether value sent is not correct");
    require(isTokenValid(msg.sender, _merkleProof), "invalid merkle proof");
    require(ts + _numberOfTokens <= MAX_SUPPLY, "Purchase would exceed max tokens");

    _safeMint(msg.sender, _numberOfTokens);
  }

  function mint(uint8 _numberOfTokens) external payable nonReentrant {
    uint256 ts = totalSupply();
    require(isPublicSaleActive, "Sale must be active");
    require(_numberOfTokens <= PURCHASE_LIMIT, "Exceeded max value to purchase");
    require(PRICE_PER_TOKEN * _numberOfTokens <= msg.value, "Ether value sent is not correct");
    require(ts + _numberOfTokens <= MAX_SUPPLY, "Purchase would exceed max tokens");

    _safeMint(msg.sender, _numberOfTokens);
  }

  function reserveNFTs(uint8 _numberOfTokens) external nonReentrant {
    uint256 ts = totalSupply();
    require(isDevAllowListActive, "Allow list is not active");
    require(_devAllowList[msg.sender] >= 0, "msg.sender is Not in allow list");
    require(_numberOfTokens <= _devAllowList[msg.sender], "Exceeded max token purchase");
    require(ts + _numberOfTokens <= MAX_SUPPLY, "Purchase would exceed max tokens");

    _devAllowList[msg.sender] -= _numberOfTokens;
    _safeMint(msg.sender, _numberOfTokens);
  }

  function tokensOfOwner(address _owner) external view returns (uint256[] memory) {
    uint256 tokenCount = balanceOf(_owner);
    uint256[] memory tokensId = new uint256[](tokenCount);
    for (uint256 i = 0; i < tokenCount; i++) {
      tokensId[i] = tokenOfOwnerByIndex(_owner, i);
    }

    return tokensId;
  }

  // metadata URI

  function _baseURI() internal view virtual override returns (string memory) {
    return _baseTokenURI;
  }

  function setBaseURI(string calldata baseURI) external onlyOwner {
    _baseTokenURI = baseURI;
  }

  function tokenURI(uint256 tokenId) public view override(ERC721A) returns (string memory) {
    require(_exists(tokenId), "Token does not exist");
    if (isShowMetadataActive) {
      return string(abi.encodePacked(_baseTokenURI, tokenId.toString()));
    }
    return "Token URI is hidden.";
  }

  function withdraw() external onlyOwner {
    uint256 balance = address(this).balance;
    require(balance > 0, "No ether left to withdraw");
    payable(msg.sender).transfer(balance);
  }
}
