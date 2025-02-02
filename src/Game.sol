// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {GameBank} from "./Bank.sol";
import "./libraries/MonopolyLibrary.sol";
import {console} from "forge-std/Test.sol";

interface INFTContract {
    function returnProperty(uint8 propertyId) external view returns (MonopolyLibrary.Property memory property);

    function returnPropertyRent(uint8 propertyId, uint8 upgradeStatus) external view returns (uint256 rent);
}

interface IPlayerContract {
    function playerUsernames(address player) external view returns (bytes memory);
    function alreadyRegistered(address _player) external view returns (bool);
}

interface IDice {
    function rollDice() external view returns (uint8, uint8);
}

contract Game {
    GameBank public gameBank;
    INFTContract private nftContract;
    IPlayerContract private iPlayerContract;
    IDice private iDice;
    uint8 public numberOfPlayers;

    using MonopolyLibrary for MonopolyLibrary.PropertyG;
    using MonopolyLibrary for MonopolyLibrary.Player;

    mapping(address => bool) public isPlayer;
    mapping(address => uint8) playersPosition;
    mapping(address => MonopolyLibrary.Player) players;
    uint8 public currentPlayerIndex;
    bool gameStarted;

    event PlayerMoved(address indexed player, uint8 newPosition);
    event TurnChanged(address indexed nextPlayer);

    address[] playerAddresses;

    event GameStarted(uint8 numberOfPlayers, address[] players);

    constructor(
        address _nftContract,
        address _playerAddress,
        address _playerContract,
        address _diceContract, 
        bool isPrivateGame,
        uint8 _numberOfPlayers
    ) {
        require(_playerContract.code.length > 0, "Not a contract address");
        require(_diceContract.code.length > 0, "Not a contract address");
        require(_nftContract.code.length > 0 , "Not a contract address ");
        iPlayerContract = IPlayerContract(_playerContract);
        iDice = IDice(_diceContract);

        if (isPrivateGame) {
           require(_numberOfPlayers > 1 , "players must be more than one");

        }
        gameBank = new GameBank(8, _nftContract);
    }

    /**
     * @dev Initializes the game with the provided players.
     *      Calls the bank contract to mint tokens for each player and disburses funds.
     * @return success Returns true if the game starts successfully.
     * @notice Emits a `GameStarted` event upon successful execution.
     */
    function startGame() external returns (bool success) {
        for (uint8 i = 0; i < playerAddresses.length; i++) {
            require(isPlayer[playerAddresses[i]], "Address is not a registered player");
            // Mint tokens for each player via the GameBank
            gameBank.mint(playerAddresses[i], 1500);
        }
        currentPlayerIndex = 0;
        gameStarted = true;
        emit GameStarted(numberOfPlayers, playerAddresses);
        return true;
    }

    function play(address _currentPlayer) external {
        MonopolyLibrary.Player storage player = players[_currentPlayer];
        require(gameStarted, "Game not started yet");
        require(playerAddresses[currentPlayerIndex] == _currentPlayer, "Not your turn");

        // Roll the dice
        (uint8 dice1, uint8 dice2) = iDice.rollDice();

        uint8 totalMove = dice1 + dice2;
        // player.diceRolled = totalMove;

        // Check if player is in jail
        if (player.inJail) {
            //     // Check if the player rolled doubles
            if (dice1 == dice2) {
                player.inJail = false; // Player is out of jail
                player.jailAttemptCount = 0; // Reset attempt count
                player.playerCurrentPosition += totalMove;
                player.diceRolled = totalMove;
            } else {
                player.jailAttemptCount += 1;
                if (player.jailAttemptCount > 2) {
                    player.inJail = false; // Player is out of jail
                    player.jailAttemptCount = 0; // Reset attempt count
                }
            }
        } else {
            player.playerCurrentPosition += totalMove;
            player.diceRolled = totalMove;
        }

        // Check if the player passed 'Go'
        if (!player.inJail && player.playerCurrentPosition > 40) {
            player.playerCurrentPosition %= 40; // Reset position to within board range
            gameBank.mint(player.addr, 200); // Reward for passing Go
        }

        // Emit an event for the move
        emit PlayerMoved(player.addr, player.playerCurrentPosition);

        // Advance the turn to the next player
    }

    

    function buyProperty(address _currentPlayer) external {
        require(gameStarted, "Game not started yet");
        MonopolyLibrary.Player memory player = players[_currentPlayer];
        require(playerAddresses[currentPlayerIndex] == _currentPlayer, "Can Only buy Properties During Your Turn");
        uint8 propertyId = player.playerCurrentPosition;
        gameBank.buyProperty(propertyId, _currentPlayer);
    }

    function openTrade(
        uint8 usersPropertyId,
        uint8 teamMatePropertyID,
        MonopolyLibrary.SwapType swapType,
        uint256 biddingAmount,
        address _teamMateAddress
    ) external {
        MonopolyLibrary.Player memory player = players[msg.sender];

        MonopolyLibrary.PropertyG memory teamMateProperty = getProperty(teamMatePropertyID);
        require(gameStarted, "Game not started yet");
        // require(playerAddresses[currentPlayerIndex] == player.addr, "Not your turn");

        address teamMateAddress;
        teamMateAddress = teamMateProperty.owner;
        if (swapType == MonopolyLibrary.SwapType.CASH_FOR_PROPERTY) {
            teamMateAddress = _teamMateAddress;
        }

        //        gameBank.proposePropertySwap(
        //            msg.sender, teamMateAddress, usersPropertyId, teamMatePropertyID, swapType, biddingAmount
        //        );
    }

    function counterDeal(
        uint8 usersPropertyId,
        uint8 teamMatePropertyID,
        MonopolyLibrary.SwapType swapType,
        uint256 biddingAmount
    ) external {
        require(gameStarted, "Game not started yet");
        //        gameBank.counterDeal(msg.sender, usersPropertyId, teamMatePropertyID, swapType, biddingAmount);
    }

    function acceptTrade() external {
        require(gameStarted, "Game not started yet");
        //        gameBank.acceptDeal(msg.sender);
    }

    function rejectDeal() external {
        require(gameStarted, "Game not started yet");
        //        gameBank.rejectDeal(msg.sender);
    }

    function handleRent(address _currentPlayer) external {
        require(gameStarted, "Game not started yet");
        MonopolyLibrary.Player memory player = players[_currentPlayer];
        require(playerAddresses[currentPlayerIndex] == _currentPlayer, "Not your turn");
        uint8 diceRolled = player.diceRolled;
        uint8 propertyId = player.playerCurrentPosition;
        gameBank.handleRent(_currentPlayer, propertyId, diceRolled);
    }

    function mortgageProperty(uint8 propertyID, address _currentPlayer) external {
        require(gameStarted, "Game not started yet");
        // MonopolyLibrary.Player memory player = players[_currentPlayer];
        require(playerAddresses[currentPlayerIndex] == _currentPlayer, "Not your turn");
        // require(property.owner == msg.sender, "not your property");

        gameBank.mortgageProperty(propertyID, _currentPlayer);
    }

    function releaseMortgage(uint8 _propertyId, address _currentPlayer) external {
        require(gameStarted, "Game not started yet");
        // MonopolyLibrary.Player memory player = players[msg.sender];

        // MonopolyLibrary.PropertyG memory property = getProperty(_propertyID);
        require(playerAddresses[currentPlayerIndex] == _currentPlayer, "Not your turn");
        // require(property.owner == msg.sender, "not your property");

        gameBank.releaseMortgage(_propertyId, _currentPlayer);
    }

    function upgradeProperty(uint8 propertyId, uint8 noOfIntendedUpgrade, address _currentPlayer) external {
        require(gameStarted, "Game not started yet");
        require(playerAddresses[currentPlayerIndex] == _currentPlayer, "Not your turn");
        gameBank.upgradeProperty(propertyId, noOfIntendedUpgrade, _currentPlayer);
    }

    function downgradeProperty(uint8 propertyId, uint8 requestedDowngrades, address _currentPlayer) external {
        require(gameStarted, "Game not started yet");
        require(playerAddresses[currentPlayerIndex] == _currentPlayer, "Not your turn");
        gameBank.downgradeProperty(propertyId, requestedDowngrades, _currentPlayer);
    }

    /**
     * @dev Advance to the next player's turn.
     */
    function nextTurn() external {
        require(gameStarted, "Game not started yet");
        require(playerAddresses.length > 0, "No players available");

        // Update the currentPlayerIndex to the next player in a circular manner
        currentPlayerIndex = uint8((currentPlayerIndex + 1) % playerAddresses.length);

        // emit TurnChanged(playersPosition[currentPlayerIndex]);
    }

    /**
     * @dev Get the current player's address.
     * @return The address of the current player.
     */
    function getCurrentPlayer() external view returns (address) {
        require(gameStarted, "Game not started yet");
        return playerAddresses[currentPlayerIndex];
    }

    //HELPER FUNCTIONS FOR TESTING

    function returnPlayer(address _playersAddress) external view returns (MonopolyLibrary.Player memory player) {
        player = players[_playersAddress];
        player.cash = gameBank.balanceOf(_playersAddress);
        return player;
    }

    function returnPropertyNft(uint8 propertyId) public view returns (MonopolyLibrary.Property memory property) {
        property = nftContract.returnProperty(propertyId);
        return property;
    }

    function playersBalances(address _playersAddress) external view returns (uint256 playersBal) {
        playersBal = gameBank.balanceOf(_playersAddress);
        return playersBal;
    }

    function getProperty(uint8 propertyId) public view returns (MonopolyLibrary.PropertyG memory property) {
        property = gameBank.getProperty(propertyId);
        return property;
    }

    function getPropertyOwner(uint8 propertyId) external view returns (address _propertyOwner) {
        _propertyOwner = gameBank.getPropertyOwner(propertyId);
        return _propertyOwner;
    }

    function returnDeal(address user) public view returns (MonopolyLibrary.PropertySwap memory usersDeal) {
        usersDeal = gameBank.returnProposal(user);
        return usersDeal;
    }

    function getPropertyRent(uint8 id, uint8 upgradeStatus) public view returns (uint256 rent) {
        rent = nftContract.returnPropertyRent(id, upgradeStatus);
        return rent;
    }

    function mintMoreTokens(address user) public {
        gameBank.mint(user, 15000);
    }
}
