// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "erc721a/contracts/ERC721A.sol";

contract Collection is ERC721A, Ownable, ReentrancyGuard {
  using Strings for uint256;

  /// @notice Event emitted when user minted tokens.
  event Minted(address user, uint256 quantity, uint256 totalSupply);

  uint256 public immutable maxTokensPerTx;
  uint256 public immutable maxSupply;
  uint256 public immutable price;
  uint256 public immutable startingTime;

  string private _baseTokenURI;

  bool public isSaleActive = false;

  constructor(
    string memory name,
    string memory symbol,
    uint256 _maxTokensPerTx,
    uint256 _maxSupply,
    uint256 _price,
    uint256 _startingTime
  ) ERC721A(name, symbol) {
    maxTokensPerTx = _maxTokensPerTx;
    maxSupply = _maxSupply;
    price = _price;
    startingTime = _startingTime;
  }

  modifier callerIsUser() {
    require(tx.origin == msg.sender, "The caller is another contract");
    _;
  }

  /*
   * Pause sale if active, make active if paused
   */
  function flipIsSaleState() external onlyOwner {
    isSaleActive = !isSaleActive;
  }

  // Prize minting at the first time
  function prizeMint() external onlyOwner nonReentrant {
    _safeMint(msg.sender, 1);
  }

  function mint(uint256 _quantity) external payable callerIsUser nonReentrant {
    require(isSaleActive, "Sale is not active");
    require(block.timestamp >= startingTime, "Not a time to purchase");
    require(_quantity <= maxTokensPerTx, "Exceeds max per transaction");
    require(totalSupply() + _quantity <= maxSupply, "Purchase would exceed max supply");
    require(price * _quantity <= msg.value, "Incorrect funds");

    _safeMint(msg.sender, _quantity);

    emit Minted(msg.sender, _quantity, totalSupply());
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
