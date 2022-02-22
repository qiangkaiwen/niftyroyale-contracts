// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract BattleRoyaleRandom is ERC721URIStorage, Ownable {
  using SafeERC20 for IERC20;

  /// @notice Event emitted when contract is deployed.
  event BattleRoyaleRandomDeployed();

  /// @notice Event emitted when owner withdrew the ETH.
  event EthWithdrew(address receiver);

  /// @notice Event emitted when owner withdrew the ERC20 token.
  event ERC20TokenWithdrew(address receiver);

  /// @notice Event emitted when user purchased the tokens.
  event Purchased(address user, uint256 amount, uint256 totalSupply);

  /// @notice Event emitted when owner has set starting time.
  event StartingTimeSet(uint256 time);

  /// @notice Event emitted when battle has started.
  event BattleStarted(address battleAddress, uint32[] inPlay);

  /// @notice Event emitted when battle has ended.
  event BattleEnded(address battleAddress, uint256 winnerTokenId, string prizeTokenURI);

  /// @notice Event emitted when token URIs set.
  event TokenURIsAdded(string[] tokenURIs);

  /// @notice Event emitted when token URI has updated.
  event TokenURIUpdated(uint256 index, string tokenURI);

  /// @notice Event emitted when token URI has removed.
  event TokenURIRemoved(uint256 index, string[] tokenURIs);

  /// @notice Event emitted when prize token uri set.
  event PrizeTokenURISet(string prizeTokenURI);

  /// @notice Event emitted when token price set.
  event PriceSet(uint256 price);

  /// @notice Event emitted when the units per transaction set.
  event UnitsPerTransactionSet(uint256 defaultTokenURI);

  /// @notice Event emitted when max supply set.
  event MaxSupplySet(uint256 maxSupply);

  enum BATTLE_STATE {
    STANDBY,
    RUNNING,
    ENDED
  }

  BATTLE_STATE public battleState;

  string public prizeTokenURI;
  string[] public tokenURIs;

  uint256 public price;
  uint256 public maxSupply;
  uint256 public totalSupply;
  uint256 public unitsPerTransaction;
  uint256 public startingTime;

  uint32[] public inPlay;

  /**
   * @dev Constructor function
   * @param _name Token name
   * @param _symbol Token symbol
   * @param _price Token price
   * @param _unitsPerTransaction Purchasable token amounts per transaction
   * @param _maxSupply Maximum number of mintable tokens
   */
  constructor(
    string memory _name,
    string memory _symbol,
    uint256 _price,
    uint256 _unitsPerTransaction,
    uint256 _maxSupply
  ) ERC721(_name, _symbol) {
    battleState = BATTLE_STATE.STANDBY;
    price = _price;
    unitsPerTransaction = _unitsPerTransaction;
    maxSupply = _maxSupply;

    emit BattleRoyaleRandomDeployed();
  }

  /**
   * @dev External function to purchase tokens.
   * @param _amount Token amount to buy
   */
  function purchase(uint256 _amount) external payable {
    require(
      battleState == BATTLE_STATE.STANDBY,
      "BattleRoyaleRandom: Current battle state is not ready to purchase tokens"
    );
    require(
      maxSupply > 0 && totalSupply < maxSupply,
      "BattleRoyaleRandom: Total token amount is more than max supply"
    );

    require(
      tokenURIs.length >= _amount,
      "BattleRoyaleRandom: Token uris are not enough to purchase"
    );

    require(block.timestamp >= startingTime, "BattleRoyaleRandom: Not time to purchase");

    if (msg.sender != owner()) {
      require(
        _amount <= maxSupply - totalSupply && _amount > 0 && _amount <= unitsPerTransaction,
        "BattleRoyaleRandom: Out range of token amount"
      );
      require(
        msg.value >= (price * _amount),
        "BattleRoyaleRandom: Caller hasn't got enough ETH for buying tokens"
      );
    }

    for (uint256 i = 0; i < _amount; i++) {
      uint256 tokenId = totalSupply + i + 1;

      _safeMint(msg.sender, tokenId);

      uint256 index = uint256(
        keccak256(abi.encode(i, _amount, block.timestamp, msg.sender, tokenId))
      ) % tokenURIs.length;

      string memory tokenURI = tokenURIs[index];

      _setTokenURI(tokenId, tokenURI);

      tokenURIs[index] = tokenURIs[tokenURIs.length - 1];
      tokenURIs.pop();

      inPlay.push(uint32(tokenId));
    }

    totalSupply += _amount;

    emit Purchased(msg.sender, _amount, totalSupply);
  }

  /**
   * @dev External function to set starting time. This function can be called only by owner.
   */
  function setStartingTime(uint256 _newTime) external onlyOwner {
    startingTime = _newTime;

    emit StartingTimeSet(_newTime);
  }

  /**
   * @dev External function to start the battle. This function can be called only by owner.
   */
  function startBattle() external onlyOwner {
    require(
      bytes(prizeTokenURI).length > 0 && inPlay.length > 1,
      "BattleRoyaleRandom: Tokens in game are not enough to play"
    );
    battleState = BATTLE_STATE.RUNNING;

    emit BattleStarted(address(this), inPlay);
  }

  /**
   * @dev External function to end the battle. This function can be called only by owner.
   * @param _winnerTokenId Winner token Id in battle
   */
  function endBattle(uint256 _winnerTokenId) external onlyOwner {
    require(battleState == BATTLE_STATE.RUNNING, "BattleRoyaleRandom: Battle is not started");
    battleState = BATTLE_STATE.ENDED;

    _setTokenURI(_winnerTokenId, prizeTokenURI);

    emit BattleEnded(address(this), _winnerTokenId, prizeTokenURI);
  }

  /**
   * @dev External function to add token URIs. This function can be called only by owner.
   * @param _tokenURIs Array of new token uris
   */
  function addTokenURIs(string[] memory _tokenURIs) external onlyOwner {
    for (uint256 i = 0; i < _tokenURIs.length; i++) {
      tokenURIs.push(_tokenURIs[i]);
    }

    emit TokenURIsAdded(_tokenURIs);
  }

  /**
   * @dev External function to update the token uri. This function can be called only by owner.
   * @param _index Index of token uri
   * @param _tokenURI Array of new token uris
   */
  function updateTokenURI(uint256 _index, string memory _tokenURI) external onlyOwner {
    tokenURIs[_index] = _tokenURI;

    emit TokenURIUpdated(_index, _tokenURI);
  }

  /**
   * @dev External function to remove the token uri. This function can be called only by owner.
   * @param _index Index of token uri
   */
  function removeTokenURI(uint256 _index) external onlyOwner {
    tokenURIs[_index] = tokenURIs[tokenURIs.length - 1];
    tokenURIs.pop();

    emit TokenURIRemoved(_index, tokenURIs);
  }

  /**
   * @dev External function to set the prize token URI. This function can be called only by owner.
   * @param _tokenURI New prize token uri
   */
  function setPrizeTokenURI(string memory _tokenURI) external onlyOwner {
    prizeTokenURI = _tokenURI;

    emit PrizeTokenURISet(prizeTokenURI);
  }

  /**
   * @dev External function to set the token price. This function can be called only by owner.
   * @param _price New token price
   */
  function setPrice(uint256 _price) external onlyOwner {
    price = _price;

    emit PriceSet(price);
  }

  /**
   * @dev External function to set the limit of buyable token amounts. This function can be called only by owner.
   * @param _unitsPerTransaction New purchasable token amounts per transaction
   */
  function setUnitsPerTransaction(uint256 _unitsPerTransaction) external onlyOwner {
    unitsPerTransaction = _unitsPerTransaction;

    emit UnitsPerTransactionSet(unitsPerTransaction);
  }

  /**
   * @dev External function to set max supply. This function can be called only by owner.
   * @param _maxSupply New maximum token amounts
   */
  function setMaxSupply(uint256 _maxSupply) external onlyOwner {
    maxSupply = _maxSupply;

    emit MaxSupplySet(maxSupply);
  }

  /**
   * Fallback function to receive ETH
   */
  receive() external payable {}

  /**
   * @dev External function to withdraw ETH in contract. This function can be called only by owner.
   * @param _amount ETH amount
   */
  function withdrawETH(uint256 _amount) external onlyOwner {
    uint256 balance = address(this).balance;
    require(_amount <= balance, "BattleRoyaleRandom: Out of balance");

    payable(msg.sender).transfer(_amount);

    emit EthWithdrew(msg.sender);
  }

  /**
   * @dev External function to withdraw ERC-20 tokens in contract. This function can be called only by owner.
   * @param _tokenAddr Address of ERC-20 token
   * @param _amount ERC-20 token amount
   */
  function withdrawERC20Token(address _tokenAddr, uint256 _amount) external onlyOwner {
    IERC20 token = IERC20(_tokenAddr);

    uint256 balance = token.balanceOf(address(this));
    require(_amount <= balance, "BattleRoyaleRandom: Out of balance");

    token.safeTransfer(msg.sender, _amount);

    emit ERC20TokenWithdrew(msg.sender);
  }
}
