// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {GameBank} from "./Bank.sol";
import "./libraries/MonopolyLibrary.sol";
import {console} from "forge-std/Test.sol";

/**
 * @title Game Contract
 * @dev Handles the core mechanics of a Monopoly-style game
 */
interface INFTContract {
    function properties(
        uint8 propertyId
    ) external view returns (MonopolyLibrary.Property memory property);

    function getProperty(uint8 propertyId) external returns (MonopolyLibrary.Property memory);

    function returnPropertyRent(
        uint8 propertyId,
        uint8 upgradeStatus
    ) external view returns (uint256 rent);
}

interface IPlayerContract {
    function playerUsernames(
        address player
    ) external view returns (bytes memory);

    function alreadyRegistered(address _player) external view returns (bool);
    function playerSmartAccount(address _playerAddress) external view returns (address);
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
    uint8 public numberOfAddedPlayers;

    using MonopolyLibrary for MonopolyLibrary.PropertyG;
    using MonopolyLibrary for MonopolyLibrary.Player;

    mapping(address => bool) public isPlayer;
    mapping(address => uint8) playersPosition;
    mapping(address => MonopolyLibrary.Player) public players;
    uint8 public currentPlayerIndex;
    bool public gameStarted;
    address[] public playerAddresses;

    event PlayerMoved(address indexed player, uint8 newPosition);
    event TurnChanged(address indexed nextPlayer);
    event GameStarted(uint8 numberOfPlayers, address[] players);

    /**
     * @dev Initializes the game contract
     * @param _nftContract Address of the NFT contract managing properties
     * @param _playerAddress Address of the first player
     * @param _playerContract Address of the player contract
     * @param _diceContract Address of the dice contract
     * @param isPrivateGame Indicates if the game is private
     * @param _numberOfPlayers Number of players allowed in the game
     */
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
        require(_nftContract.code.length > 0, "Not a contract address");

        iPlayerContract = IPlayerContract(_playerContract);
        iDice = IDice(_diceContract);
        nftContract = INFTContract(_nftContract);

        createBankAndAssignNumberOfPlayers(_numberOfPlayers, _nftContract);

        if (isPrivateGame) {
            require(
                _numberOfPlayers > 1 && _numberOfPlayers <= 10,
                "Invalid number of players"
            );
            createPlayer(_playerAddress);
        }
    }

    /**
     * @dev Creates the game bank and assigns the number of players
     * @param _numberOfPlayers Number of players
     * @param _nftContract Address of the NFT contract
     */
    function createBankAndAssignNumberOfPlayers(
        uint8 _numberOfPlayers,
        address _nftContract
    ) private {
        gameBank = new GameBank(_numberOfPlayers, _nftContract);
        numberOfPlayers = _numberOfPlayers;
    }

    /**
     * @dev Creates a player in the game
     * @param _playerAddress Address of the player to add
     */
    function createPlayer(address _playerAddress) private {
        isPlayer[_playerAddress] = true;
        address playerSmartAccount = iPlayerContract.playerSmartAccount(_playerAddress);
        playerAddresses.push(playerSmartAccount);
        MonopolyLibrary.Player storage player = players[_playerAddress];
        player.username = string(
            iPlayerContract.playerUsernames(_playerAddress)
        );

        player.addr = playerSmartAccount;
        numberOfAddedPlayers += 1;
    }

    /**
     * @dev Adds a player to the game
     * @param _playerAddress Address of the player to add
     */
    function addPlayer(address _playerAddress) external {
        require(numberOfAddedPlayers < numberOfPlayers, "Game is full");
        require(!isPlayer[_playerAddress], "Address already registered");
        createPlayer(_playerAddress);
    }

    /**
     * @dev Starts the game and distributes initial funds to players
     * @return success Returns true if the game starts successfully
     */
    function startGame() external returns (bool success) {
        require(
            numberOfAddedPlayers == numberOfPlayers,
            "Not all players registered"
        );
        for (uint8 i = 0; i < playerAddresses.length; i++) {
            gameBank.mint(playerAddresses[i], 1500);
        }
        gameStarted = true;
        emit GameStarted(numberOfPlayers, playerAddresses);
        return true;
    }

    /**
     * @dev Handles player movement by rolling the dice
     * @param _currentPlayer Address of the player rolling the dice
     */
    function play(address _currentPlayer) external {
        require(gameStarted, "Game not started yet");
        require(
            playerAddresses[currentPlayerIndex] == _currentPlayer,
            "Not your turn"
        );

        (uint8 dice1, uint8 dice2) = iDice.rollDice();
        uint8 totalMove = dice1 + dice2;
        MonopolyLibrary.Player storage player = players[_currentPlayer];

        if (player.inJail) {
            if (dice1 == dice2) {
                player.inJail = false;
                player.jailAttemptCount = 0;
                player.playerCurrentPosition += totalMove;
            } else {
                player.jailAttemptCount += 1;
                if (player.jailAttemptCount > 2) {
                    player.inJail = false;
                    player.jailAttemptCount = 0;
                }
            }
        } else {
            player.playerCurrentPosition += totalMove;
        }

        if (!player.inJail && player.playerCurrentPosition > 40) {
            player.playerCurrentPosition %= 40;
            gameBank.mint(player.addr, 200);
        }
        emit PlayerMoved(player.addr, player.playerCurrentPosition);
    }

    function buyProperty(address _playerAddress) external {
        require(gameStarted, "Game not started yet");
        require(
            playerAddresses[currentPlayerIndex] == _playerAddress,
            "Not your turn"
        );

        MonopolyLibrary.Player memory player = players[_playerAddress];

        gameBank.buyProperty(player.playerCurrentPosition, _playerAddress);
    }

    function handleRent(address _playerAddress) external {
        require(gameStarted, "Game not started yet");
        require(
            playerAddresses[currentPlayerIndex] == _playerAddress,
            "Not your turn"
        );

        MonopolyLibrary.Player memory player = players[_playerAddress];
        gameBank.handleRent(_playerAddress, player.playerCurrentPosition, player.diceRolled);
    }

    /**
     * @dev Moves to the next player's turn
     */
    function nextTurn() external {
        require(gameStarted, "Game not started yet");
        currentPlayerIndex = uint8(
            (currentPlayerIndex + 1) % playerAddresses.length
        );
        emit TurnChanged(playerAddresses[currentPlayerIndex]);
    }

    /**
     * @dev Gets the current player's address
     * @return The address of the current player
     */
    function getCurrentPlayer() external view returns (address) {
        require(gameStarted, "Game not started yet");
        return playerAddresses[currentPlayerIndex];
    }

    //HELPER FUNCTIONS FOR TESTING

    function returnPlayer(
        address _playersAddress
    ) external view returns (MonopolyLibrary.Player memory player) {
        player = players[_playersAddress];
        player.cash = gameBank.balanceOf(_playersAddress);
        return player;
    }

    function returnPropertyNft(
        uint8 propertyId
    ) public returns (MonopolyLibrary.Property memory property) {
        // (bytes memory _name,
        // uint256 _rentAmount,    
        // bytes memory _uri,
        // uint256 _buyAmount,
        // MonopolyLibrary.PropertyType _propertyType,
        // MonopolyLibrary.PropertyColors _color)= nftContract.properties(propertyId);

        // property.name = _name;
        // property.rentAmount = _rentAmount;
        // property.buyAmount = _buyAmount;
        // property.uri = _uri;
        // property.propertyType = _propertyType;
        // property.color = _color;

       property = nftContract.getProperty(propertyId);

        return property;
    }

    function playersBalances(
        address _playersAddress
    ) external view returns (uint256 playersBal) {
        playersBal = gameBank.balanceOf(_playersAddress);
        return playersBal;
    }

    function getProperty(
        uint8 propertyId
    ) public view returns (MonopolyLibrary.PropertyG memory property) {
        property = gameBank.getProperty(propertyId);
        return property;
    }

    function getPropertyOwner(
        uint8 propertyId
    ) external view returns (address _propertyOwner) {
        _propertyOwner = gameBank.getPropertyOwner(propertyId);
        return _propertyOwner;
    }

    function returnDeal(
        address user
    ) public view returns (MonopolyLibrary.PropertySwap memory usersDeal) {
        usersDeal = gameBank.returnProposal(user);
        return usersDeal;
    }

    function getPropertyRent(
        uint8 id,
        uint8 upgradeStatus
    ) public view returns (uint256 rent) {
        rent = nftContract.returnPropertyRent(id, upgradeStatus);
        return rent;
    }

    function mintMoreTokens(address user) public {
        gameBank.mint(user, 15000);
    }
}

//     address _playersAddress
// function playerNetWorth() external view returns (uint256) {
//     player = players[_playersAddress];
//     player.networth = playersBalances(player.addr) ;
// }
