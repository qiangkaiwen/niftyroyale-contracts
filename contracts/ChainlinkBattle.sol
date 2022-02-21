// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@chainlink/contracts/src/v0.8/interfaces/KeeperCompatibleInterface.sol";

contract ChainlinkBattle is VRFConsumerBase, Ownable, KeeperCompatibleInterface {
  using SafeERC20 for IERC20;

  /// @notice Event emitted when battle is added.
  event BattleAdded(BattleInfo battle);

  /// @notice Event emitted when battle is executed.
  event BattleExecuted(uint256 battleId, bytes32 requestId);

  /// @notice Event emitted when one nft is eliminated.
  event Eliminated(address gameAddr, uint256 tokenId, bool battleState);

  /// @notice Event emitted when winner is set.
  event BattleEnded(bool finished, address gameAddr, uint256 winnerTokenId, bool battleState);

  /// @notice Event emitted when interval time is set.
  event BattleIntervalTimeSet(uint256 battleId, uint256 intervalTime);

  /// @notice Event emitted when eliminated token count is set.
  event EliminatedTokenCountSet(uint256 battleId, uint256 eliminatedTokenCount);

  bytes32 internal keyHash;
  uint256 public fee;

  mapping(bytes32 => uint256) private requestToBattle;

  struct BattleInfo {
    address gameAddr;
    uint256 intervalTime;
    uint256 lastEliminatedTime;
    uint32[] inPlay;
    uint32[] outOfPlay;
    bool battleState;
    uint256 winnerTokenId;
    uint256 eliminatedTokenCount;
  }

  BattleInfo[] public battleQueue;

  uint256 public battleQueueLength;

  /**
   * Constructor inherits VRFConsumerBase
   *
   * Network: Polygon(Matic) Mainnet
   * Chainlink VRF Coordinator address: 0x3d2341ADb2D31f1c5530cDC622016af293177AE0
   * LINK token address:                0xb0897686c545045aFc77CF20eC7A532E3120E0F1
   * Key Hash:                          0xf86195cf7690c55907b2b611ebb7343a6f649bff128701cc542f0569e2c549da
   * Fee : 0.0001LINK
   */
  constructor(
    address _vrfCoordinator,
    address _link,
    bytes32 _keyHash,
    uint256 _fee
  )
    VRFConsumerBase(
      _vrfCoordinator, // VRF Coordinator
      _link // LINK Token
    )
  {
    keyHash = _keyHash;
    fee = _fee;
  }

  /**
   * @dev External function to add battle. This function can be called only by owner.
   * @param _gameAddr Battle game address
   * @param _intervalTime Interval time
   * @param _inPlay Tokens in game
   * @param _eliminatedTokenCount Number of tokens that should be removed by one perfermUpKeep.
   */
  function addToBattleQueue(
    address _gameAddr,
    uint256 _intervalTime,
    uint32[] memory _inPlay,
    uint256 _eliminatedTokenCount
  ) external onlyOwner {
    BattleInfo memory battle;
    battle.gameAddr = _gameAddr;
    battle.intervalTime = _intervalTime;
    battle.lastEliminatedTime = block.timestamp;
    battle.inPlay = _inPlay;
    battle.battleState = true;
    battle.eliminatedTokenCount = _eliminatedTokenCount;

    battleQueue.push(battle);
    battleQueueLength++;

    emit BattleAdded(battle);
  }

  /**
   * @dev External function to check if the contract requires work to be done.
   * @param _checkData Data passed to the contract when checking for upkeep.
   * @return upkeepNeeded boolean to indicate whether the keeper should call performUpkeep or not.
   * @return performData bytes that the keeper should call performUpkeep with, if upkeep is needed.
   */
  function checkUpkeep(bytes calldata _checkData)
    external
    view
    override
    returns (bool, bytes memory)
  {
    for (uint256 i = 0; i < battleQueue.length; i++) {
      BattleInfo memory battle = battleQueue[i];
      if (
        battle.battleState == true &&
        block.timestamp >= battle.lastEliminatedTime + (battle.intervalTime * 1 minutes)
      ) {
        return (true, abi.encodePacked(i));
      }
    }
    return (false, _checkData);
  }

  /**
   * @dev Performs work on the contract. Executed by the keepers, via the registry.
   * @param _performData is the data which was passed back from the checkData simulation.
   */
  function performUpkeep(bytes calldata _performData) external override {
    uint256 battleId = bytesToUint256(_performData, 0);
    BattleInfo memory battle = battleQueue[battleId];

    require(battle.battleState, "ChainlinkKeeper: Current battle is finished");
    require(
      block.timestamp >= battle.lastEliminatedTime + (battle.intervalTime * 1 minutes),
      "ChainlinkKeeper: Trigger time is not correct"
    );

    executeBattle(battleId);
  }

  /**
   * @dev Internal function to execute battle.
   * @param _battleId Battle Id
   */
  function executeBattle(uint256 _battleId) internal {
    BattleInfo storage battle = battleQueue[_battleId];

    require(LINK.balanceOf(address(this)) >= fee, "ChainlinkKeeper: Not enough LINK");
    require(battle.battleState, "ChainlinkKeeper: Current battle is finished");

    bytes32 requestId = requestRandomness(keyHash, fee);
    requestToBattle[requestId] = _battleId;
    battle.lastEliminatedTime = block.timestamp;

    emit BattleExecuted(_battleId, requestId);
  }

  /**
   * @dev Callback function used by VRF Coordinator.
   * @param _requestId Request Id
   * @param _randomness Random Number
   */
  function fulfillRandomness(bytes32 _requestId, uint256 _randomness) internal override {
    uint256 _battleId = requestToBattle[_requestId];
    BattleInfo storage battle = battleQueue[_battleId];
    uint256 eliminatedTokenCount = battle.eliminatedTokenCount;

    if (eliminatedTokenCount >= battle.inPlay.length) {
      eliminatedTokenCount = battle.inPlay.length - 1;
    }

    for (uint256 index = 0; index < eliminatedTokenCount; index++) {
      uint256 i = uint256(keccak256(abi.encode(_randomness, index, block.timestamp))) %
        battle.inPlay.length;

      uint32 tokenId = battle.inPlay[i];

      battle.outOfPlay.push(tokenId);
      battle.inPlay[i] = battle.inPlay[battle.inPlay.length - 1];
      battle.inPlay.pop();

      emit Eliminated(battle.gameAddr, tokenId, true);
    }

    if (battle.inPlay.length == 1) {
      battle.battleState = false;
      battle.winnerTokenId = battle.inPlay[0];
      emit BattleEnded(true, battle.gameAddr, battle.winnerTokenId, false);
    }
  }

  /**
   * @dev External function to set battle interval time. This function can be called only by owner.
   * @param _battleId Battle Id
   * @param _intervalTime New interval time
   */
  function setBattleIntervalTime(uint256 _battleId, uint256 _intervalTime) external onlyOwner {
    BattleInfo storage battle = battleQueue[_battleId];
    battle.intervalTime = _intervalTime;

    emit BattleIntervalTimeSet(_battleId, _intervalTime);
  }

  /**
   * @dev External function to set eliminated token count. This function can be called only by owner.
   * @param _battleId Battle Id
   * @param _eliminatedTokenCount New eliminated token count
   */
  function setEliminatedTokenCount(uint256 _battleId, uint256 _eliminatedTokenCount)
    external
    onlyOwner
  {
    BattleInfo storage battle = battleQueue[_battleId];
    battle.eliminatedTokenCount = _eliminatedTokenCount;

    emit EliminatedTokenCountSet(_battleId, _eliminatedTokenCount);
  }

  /**
   * @dev External function to get in-play tokens.
   * @param _battleId Battle Id
   */
  function getInPlay(uint256 _battleId) external view returns (uint32[] memory) {
    return battleQueue[_battleId].inPlay;
  }

  /**
   * @dev External function to get out-play tokens.
   * @param _battleId Battle Id
   */
  function getOutPlay(uint256 _battleId) external view returns (uint32[] memory) {
    return battleQueue[_battleId].outOfPlay;
  }

  /**
   * Fallback function to receive ETH
   */
  receive() external payable {}

  /**
   * @dev External function to get the current link balance in contract.
   */
  function getCurrentLinkBalance() external view returns (uint256) {
    return LINK.balanceOf(address(this));
  }

  /**
   * @dev External function to withdraw ETH in contract. This function can be called only by owner.
   * @param _amount ETH amount
   */
  function withdrawETH(uint256 _amount) external onlyOwner {
    uint256 balance = address(this).balance;
    require(_amount <= balance, "ChainlinkKeeper: Out of balance");

    payable(msg.sender).transfer(_amount);
  }

  /**
   * @dev External function to withdraw ERC-20 tokens in contract. This function can be called only by owner.
   * @param _tokenAddr Address of ERC-20 token
   * @param _amount ERC-20 token amount
   */
  function withdrawERC20Token(address _tokenAddr, uint256 _amount) external onlyOwner {
    IERC20 token = IERC20(_tokenAddr);

    uint256 balance = token.balanceOf(address(this));
    require(_amount <= balance, "ChainlinkKeeper: Out of balance");

    token.safeTransfer(msg.sender, _amount);
  }

  /**
   * @dev Internal function to convert bytes to uint256.
   * @param _bytes value
   * @param _start Start index
   */
  function bytesToUint256(bytes memory _bytes, uint256 _start) internal pure returns (uint256) {
    require(_bytes.length >= _start + 32, "ChainlinkKeeper: toUint256_outOfBounds");
    uint256 tempUint;

    assembly {
      tempUint := mload(add(add(_bytes, 0x20), _start))
    }

    return tempUint;
  }
}
