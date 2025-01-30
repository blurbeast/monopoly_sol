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
    function alreadyRegistered(address _player) external view returns(bool);
}

interface IDice {
    function rollDice() external view returns (uint256);
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

    constructor(address _nftContract, address[] memory _playerAddresses, address _playerContract, address _diceContract) {
        require(_playerContract.code.length > 0, "Not a contract address");
        iPlayerContract = IPlayerContract(_playerContract);
        require(_playerAddresses.length > 1 && _playerAddresses.length < 10, "Exceeds the allowed number of players");

        iDice = IDice(_diceContract);
        for (uint8 i = 0; i < _playerAddresses.length; i++) {
            bool isRegistered = iPlayerContract.alreadyRegistered(_playerAddresses[i]);
            require(isRegistered, "Player not registered");
            require(!isPlayer[_playerAddresses[i]], "Duplicate player address detected");
            bytes memory playerUsername = iPlayerContract.playerUsernames(_playerAddresses[i]);
            isPlayer[_playerAddresses[i]] = true;
            players[_playerAddresses[i]] = MonopolyLibrary.Player({
                username: string(playerUsername),
                addr: _playerAddresses[i],
                playerCurrentPosition: 0,
                inJail: false,
                jailAttemptCount: 0,
                cash: 0,
                diceRolled: 0
            });
            playerAddresses.push(_playerAddresses[i]);
        }

        gameBank = new GameBank(uint8(playerAddresses.length), _nftContract);
        numberOfPlayers = uint8(playerAddresses.length);
        nftContract = INFTContract(_nftContract);
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

    function play() external {
        MonopolyLibrary.Player storage player = players[msg.sender];
        require(gameStarted, "Game not started yet");
        // console.log(" player address ",playerAddresses[currentPlayerIndex]);
        // console.log("retrieved address :: ", player.addr);
        require(playerAddresses[currentPlayerIndex] == player.addr, "Not your turn");

        // Roll the dice
        (uint8 dice1, uint8 dice2) = rollDices();

        uint8 totalMove = dice1 + dice2;
        player.diceRolled = totalMove;

        // Check if player is in jail
        if (player.inJail) {
            // Check if the player rolled doubles
            if (dice1 != dice2) {
                player.jailAttemptCount++;

                // If player has failed 3 times, release them from jail
                if (player.jailAttemptCount > 1 && player.jailAttemptCount > 2) {
                    player.inJail = false; // Player is out of jail
                    player.jailAttemptCount = 0; // Reset attempt count
                } else {
                    // Player rolled doubles and gets out of jail
                    player.inJail = false;
                    player.jailAttemptCount = 0;
                    player.playerCurrentPosition += totalMove;
                }
            }
        }

        // Check if the player passed 'Go'
        if (player.playerCurrentPosition > 40) {
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
        MonopolyLibrary.Player memory player = players[msg.sender];
        // require(playerAddresses[currentPlayerIndex] == player.addr, "Not your turn");
        uint8 diceRolled = player.diceRolled;
        uint8 propertyId = player.playerCurrentPosition;
        gameBank.handleRent(msg.sender, propertyId, diceRolled);
    }

    function mortgageProperty(uint8 propertyID) external {
        require(gameStarted, "Game not started yet");
        MonopolyLibrary.Player memory player = players[msg.sender];
        // require(playerAddresses[currentPlayerIndex] == player.addr, "Not your turn");
        // require(property.owner == msg.sender, "not your property");

        gameBank.mortgageProperty(propertyID, msg.sender);
    }

    function releaseMortgage(uint8 _propertyId, address _curerntPlayer) external {
        require(gameStarted, "Game not started yet");
        MonopolyLibrary.Player memory player = players[msg.sender];

        // MonopolyLibrary.PropertyG memory property = getProperty(_propertyID);
        // require(playerAddresses[currentPlayerIndex] == player.addr, "Not your turn");
        // require(property.owner == msg.sender, "not your property");

        gameBank.releaseMortgage(_propertyId, msg.sender);
    }

    function upgradeProperty(uint8 propertyId, uint8 noOfIntendedUpgrade, address _currentPlayer) external {
        require(gameStarted, "Game not started yet");
        MonopolyLibrary.Player memory player = players[msg.sender];

        // require(playerAddresses[currentPlayerIndex] == player.addr, "Not your turn");

        gameBank.upgradeProperty(propertyId, noOfIntendedUpgrade, player.addr);
    }

    function downgradeProperty(uint8 propertyId, uint8 requestedDowngrades, address _currentPlayer) external {
        require(gameStarted, "Game not started yet");
        MonopolyLibrary.Player memory player = players[msg.sender];

        // require(playerAddresses[currentPlayerIndex] == player.addr, "Not your turn");

        gameBank.downgradeProperty(propertyId, requestedDowngrades, player.addr);
    }

    /**
     * @dev Advance to the next player's turn.
     */
    function _nextTurn() private {
        require(gameStarted, "Game not started yet");
        require(playerAddresses.length > 0, "No players available");

        // Update the currentPlayerIndex to the next player in a circular manner
        currentPlayerIndex = uint8((currentPlayerIndex + 1) % playerAddresses.length);

        // emit TurnChanged(playersPosition[currentPlayerIndex]);
    }

    // function _rollDice() private view returns (uint256) {
    //     return (uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender, blockhash(block.number - 1)))) % 6) + 1;
    // }

    function rollDices() private view returns (uint8, uint8) {
        uint8 dice1 = uint8(iDice.rollDice());
        uint8 dice2 = uint8(iDice.rollDice());

        // if (dice1 == dice2) {
        //     uint8 dice3 = uint8(iDice.rollDice());
        //     uint8 dice4 = uint8(iDice.rollDice());
        //     return (dice3 + dice1, dice2 + dice4);
        // }

        return (dice1, dice2);
    }

    /**
     * @dev Get the current player's address.
     * @return The address of the current player.
     */
    function getCurrentPlayer() external view returns (address) {
        require(gameStarted, "Game not started yet");
        return playerAddresses[currentPlayerIndex];
    }

    function advanceToNextPlayer() external {
        // Advance the turn to the next player
        MonopolyLibrary.Player storage player = players[msg.sender];
        require(gameStarted, "Game not started yet");
        // require(playerAddresses[currentPlayerIndex] == player.addr, "Not your turn");
        _nextTurn();
        emit TurnChanged(playerAddresses[currentPlayerIndex]);

        // Emit an event for the move
        emit PlayerMoved(player.addr, player.playerCurrentPosition);
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

    //    function updateProperty(uint8 propertyId, address owner) public {
    //        gameBank.updateProperty(propertyId, owner);
    //    }

    function mintMoreTokens(address user) public {
        gameBank.mint(user, 15000);
    }
}
