//SPDX-License-Identifier: MIT
pragma solidity ^ 0.8.26;

import {Test, console} from "forge-std/Test.sol";
import {Game} from "../src/Game.sol";
import {GeneralNFT} from "../src/NFT.sol";
import {PlayerS} from "../src/Players.sol";
import {Dice} from "../src/Dice.sol";
import {MonopolyLibrary} from "../src/libraries/MonopolyLibrary.sol";

contract GameTest is Test {
    Game private game;
    GeneralNFT private generalNft;
    PlayerS private players;
    Dice private dice;

    address private player1 = address(0xa);
    address private player2 = address(0xb);
    address private player3 = address(0xc);
    address private player4 = address(0xd);
    address private player5 = address(0xe);

    function setUp() external {
        generalNft = new GeneralNFT("");
        players = new PlayerS();
        dice = new Dice();
        // game = new Game(address(generalNft), player1, address(players), address(dice), false, 4);
    }

    function registerPlayers() private {
        players.registerPlayer(player1, "player 1");
        players.registerPlayer(player2, "player 2");
        players.registerPlayer(player3, "player 3");
        players.registerPlayer(player4, "player 4");
        players.registerPlayer(player5, "player 5");
    }

    function testCreateGame() external {
        game = new Game(address(generalNft), address(0), address(players), address(dice), false, 4);
        assertEq(game.numberOfPlayers(), 4);
        bool gameStarted = game.gameStarted();
        assertEq(gameStarted, false);

        uint256 playersAdded = game.numberOfAddedPlayers();
        assertEq(playersAdded, 0);

        bool isPlayer = game.isPlayer(player1);
        assertEq(isPlayer, false);

        bool isPlayer2 = game.isPlayer(player2);
        assertEq(isPlayer2, false);

        // MonopolyLibrary.Player memory player = game.players(player1);
        (string memory username,,,,,,,,) = game.players(player1);
        assertEq(username, "");

        //now add players
        registerPlayers();

        vm.expectRevert("Not all players registered");
        game.startGame();

        game.addPlayer(player1);
        game.addPlayer(player2);
        vm.expectRevert("Address already registered");
        game.addPlayer(player1);
        game.addPlayer(player3);
        game.addPlayer(player4);
        vm.expectRevert("Game is full");
        game.addPlayer(player5);

        //confirm the length of the playerAddresses
        uint8 playersAdded2 = game.numberOfAddedPlayers();
        assertEq(playersAdded2, 4);

        //confirm the isPlayer function
        bool isPlayer3 = game.isPlayer(player3);
        assertEq(isPlayer3, true);

        //confirm the player username
        (string memory afterAddedUsername,,,,,,,,) = game.players(player1);
        assertEq(afterAddedUsername, "player 1");

        //confirm the start game
        game.startGame();
        bool gameStarted2 = game.gameStarted();
        assertEq(gameStarted2, true);
    }

    function testPlayGame() external {
        // player cannot play game when the game has not yet started
        game = new Game(address(generalNft), address(0), address(players), address(dice), false, 4);
        vm.expectRevert("Game not started yet");
        game.play(player1);

        // register player
        registerPlayers();

        game.addPlayer(player1);
        game.addPlayer(player2);
        vm.expectRevert("Address already registered");
        game.addPlayer(player1);
        game.addPlayer(player3);
        game.addPlayer(player4);

        // game has started
        game.startGame();

        // the first player to player is the player at index zero
        // confirm that
        vm.expectRevert("Not your turn");
        game.play(player2);

        //play game now
        address currentPlayer = game.getCurrentPlayer();
        assertEq(currentPlayer, player1);
        game.play(player1);

        //zafter play, the turn should move to the next player
        game.nextTurn();

        //check that the next player is the player at index 1
        address nextPlayer = game.getCurrentPlayer();

        assertEq(nextPlayer, player2);
    }
}
