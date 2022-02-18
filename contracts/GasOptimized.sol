// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "erc721a/contracts/ERC721A.sol";

contract GasOptimized is ERC721A, Ownable, ReentrancyGuard {
  uint256 public constant MAX_SUPPLY = 3000;
  uint256 public constant PRICE_PER_TOKEN = 0.001 ether;
  uint256 public constant PURCHASE_LIMIT = 10;
  uint256 public constant ALLOW_LIST_MAX_MINT = 10;
  uint256 public constant RESERVE_MAX_MINT = 10;

  string private _baseTokenURI;

  bool public saleIsActive = false;
  bool public isAllowListActive = false;

  // declare bytes32 variables to store root (a hash)
  bytes32 public merkleRoot;

  constructor() ERC721A("niftyroyale", "NIFTYROYALE") {}

  // function to set the root of Merkle Tree
  function setMerkleRoot(bytes32 _root) external onlyOwner {
    merkleRoot = _root;
  }

  // create merkle leaf from supplied data
  function _generateMerkleLeaf(address _account) internal pure returns (bytes32) {
    return keccak256(abi.encodePacked(_account));
  }

  // function to verify that the given leaf belongs to a given tree using its root for comparison
  function _verifyMerkleLeaf(
    bytes32 _leafNode,
    bytes32 _merkleRoot,
    bytes32[] memory _proof
  ) internal pure returns (bool) {
    return MerkleProof.verify(_proof, _merkleRoot, _leafNode);
  }

  function setSaleState(bool _newState) public onlyOwner {
    saleIsActive = _newState;
  }

  function setIsAllowListActive(bool _isAllowListActive) external onlyOwner {
    isAllowListActive = _isAllowListActive;
  }

  function mintAllowList(uint8 _numberOfTokens, bytes32[] calldata _merkleProof)
    external
    payable
    nonReentrant
  {
    require(isAllowListActive, "Allow list is not active");
    require(_numberOfTokens <= ALLOW_LIST_MAX_MINT, "Exceeded max value to purchase");
    require(totalSupply() + _numberOfTokens <= MAX_SUPPLY, "Purchase would exceed max tokens");
    require(PRICE_PER_TOKEN * _numberOfTokens <= msg.value, "Ether value sent is not enough");
    require(
      _verifyMerkleLeaf(_generateMerkleLeaf(msg.sender), merkleRoot, _merkleProof),
      "You are not in allowlist"
    );
    _safeMint(msg.sender, _numberOfTokens);
  }

  function mint(uint256 _numberOfTokens) external payable nonReentrant {
    require(saleIsActive, "Sale must be active");
    require(_numberOfTokens <= PURCHASE_LIMIT, "Exceeded max token purchase");
    require(totalSupply() + _numberOfTokens <= MAX_SUPPLY, "Purchase would exceed max tokens");
    require(PRICE_PER_TOKEN * _numberOfTokens <= msg.value, "Ether value sent is not correct");

    _safeMint(msg.sender, _numberOfTokens);
  }

  function reserveNFTs(uint256 _numberOfTokens, bytes32[] calldata _merkleProof)
    external
    nonReentrant
  {
    require(_numberOfTokens <= RESERVE_MAX_MINT, "Exceeded max token purchase");
    require(totalSupply() + _numberOfTokens <= MAX_SUPPLY, "Purchase would exceed max tokens");
    require(
      _verifyMerkleLeaf(_generateMerkleLeaf(msg.sender), merkleRoot, _merkleProof),
      "You are not in allowlist"
    );

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

  function withdraw() external onlyOwner {
    uint256 balance = address(this).balance;
    require(balance > 0, "No ether left to withdraw");
    payable(msg.sender).transfer(balance);
  }
}
