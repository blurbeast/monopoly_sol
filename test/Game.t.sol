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
    }

    function testCreateGame() external {
        game = new Game(address(generalNft), address(0), address(players), address(dice), false, 4);
        assertEq(game.numberOfPlayers(), 4);
        bool gameStarted = game.gameStarted();
        assertEq(gameStarted, false);

        // uint256 playersAdded = game.playerAddresses().length;
        // assertEq(playersAdded, 0);

        bool isPlayer = game.isPlayer(player1);
        assertEq(isPlayer, false);

        bool isPlayer2 = game.isPlayer(player2);
        assertEq(isPlayer2, false);

        // MonopolyLibrary.Player memory player = game.players(player1);
        (string memory username,,,,,,,) = game.players(player1);
        assertEq(username, "");

        //now add players
        registerPlayers();

        game.addPlayer(player1);
        game.addPlayer(player2);
        game.addPlayer(player3);
        game.addPlayer(player4);

        //confirm the length of the playerAddresses array
        // address[] memory playersAdded2 = game.playerAddresses();
        // assertEq(playersAdded2.length, 4);

        //confirm the isPlayer function
        bool isPlayer3 = game.isPlayer(player3);
        assertEq(isPlayer3, true);

        //confirm the player username
       (string memory afterAddedUsername,,,,,,,) = game.players(player1);
        assertEq(afterAddedUsername, "player 1");




    }
}
