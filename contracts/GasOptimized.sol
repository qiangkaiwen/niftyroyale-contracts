// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "erc721a/contracts/ERC721A.sol";

contract GasOptimized is ERC721A, Ownable, ReentrancyGuard {
  uint256 public constant MAX_SUPPLY = 3000;
  uint256 public constant PRICE_PER_TOKEN = 0.001 ether;
  uint256 public allowListMaxMint = 10;

  uint256 public unitsPerTransaction;
  uint256 public dropTime;
  string private _baseTokenURI;
  bool public saleIsActive = false;
  bool public isAllowListActive = false;

  mapping(address => uint8) private _allowList;

  /// @notice Event emitted when user purchased the tokens.
  event Purchased(address user, uint256 numberOfTokens);

  /// @notice Event emitted when owner has set starting time.
  event DropTimeSet(uint256 time);

  /// @notice Event emitted when the units per transaction set.
  event UnitsPerTransactionSet(uint256 unitsPerTransaction);

  constructor(
    string memory _baseURI,
    uint256 _unitsPerTransaction,
    uint256 _dropTime
  ) ERC721A("niftyroyale", "NIFTYROYALE") {
    unitsPerTransaction = _unitsPerTransaction;
    _baseTokenURI = _baseURI;
    dropTime = _dropTime;
  }

  function setIsAllowListActive(bool _isAllowListActive) external onlyOwner {
    isAllowListActive = _isAllowListActive;
  }

  function setAllowList(address[] calldata addresses, uint8 numAllowedToMint) external onlyOwner {
    for (uint256 i = 0; i < addresses.length; i++) {
      _allowList[addresses[i]] = numAllowedToMint;
    }
  }

  function numAvailableToMint(address addr) external view returns (uint8) {
    return _allowList[addr];
  }

  function mintAllowList(uint8 numberOfTokens) external payable nonReentrant {
    require(isAllowListActive, "Allow list is not active");
    require(numberOfTokens <= _allowList[msg.sender], "Exceeded max value to purchase");
    require(totalSupply() + numberOfTokens <= MAX_SUPPLY, "Purchase would exceed max tokens");
    require(PRICE_PER_TOKEN * numberOfTokens <= msg.value, "Ether value sent is not correct");

    _allowList[msg.sender] -= numberOfTokens;
    _safeMint(msg.sender, numberOfTokens);
  }

  function mint(uint256 numberOfTokens) public payable nonReentrant {
    require(block.timestamp >= dropTime, "sale has not started yet");
    require(numberOfTokens <= unitsPerTransaction, "Exceeded max token purchase");
    require(totalSupply() + numberOfTokens <= MAX_SUPPLY, "Purchase would exceed max tokens");
    require(PRICE_PER_TOKEN * numberOfTokens <= msg.value, "Ether value sent is not correct");

    _safeMint(msg.sender, numberOfTokens);

    emit Purchased(msg.sender, numberOfTokens);
  }

  function reserveNFTs(uint256 numberOfTokens) public onlyOwner {
    require(totalSupply() + numberOfTokens <= MAX_SUPPLY, "Purchase would exceed max tokens");
    _safeMint(msg.sender, numberOfTokens);

    emit Purchased(msg.sender, numberOfTokens);
  }

  function tokensOfOwner(address _owner) external view returns (uint256[] memory) {
    uint256 tokenCount = balanceOf(_owner);
    uint256[] memory tokensId = new uint256[](tokenCount);
    for (uint256 i = 0; i < tokenCount; i++) {
      tokensId[i] = tokenOfOwnerByIndex(_owner, i);
    }

    return tokensId;
  }

  function setDropTime(uint256 _newTime) external onlyOwner {
    dropTime = _newTime;

    emit DropTimeSet(_newTime);
  }

  // metadata URI

  function _baseURI() internal view virtual override returns (string memory) {
    return _baseTokenURI;
  }

  function setBaseURI(string calldata baseURI) external onlyOwner {
    _baseTokenURI = baseURI;
  }

  function setUnitsPerTransaction(uint256 _unitsPerTransaction) external onlyOwner {
    unitsPerTransaction = _unitsPerTransaction;

    emit UnitsPerTransactionSet(unitsPerTransaction);
  }

  function withdraw() external onlyOwner {
    uint256 balance = address(this).balance;
    require(balance > 0, "No ether left to withdraw");
    payable(msg.sender).transfer(balance);
  }
}
