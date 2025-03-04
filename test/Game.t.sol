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

        // game.addPlayer(player1);
        // game.addPlayer(player2);
        // vm.expectRevert("Address already registered");
        // game.addPlayer(player1);
        // game.addPlayer(player3);
        // game.addPlayer(player4);
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

        // confirm the start game
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
        address ps2 = players.playerSmartAccount(player2);
        game.play(ps2);

        //play game now
        address ps1 = players.playerSmartAccount(player1);
        address currentPlayer = game.getCurrentPlayer();
        assertEq(currentPlayer, ps1);
        game.play(ps1);

        //zafter play, the turn should move to the next player
        game.nextTurn();

        //check that the next player is the player at index 1
        address nextPlayer = game.getCurrentPlayer();

        assertEq(nextPlayer, ps2);
    }

    // function testBuyPropertyFromBank() external {
    //     gamebank.mint(A, 1500);
    //     uint256 bal = gamebank.balanceOf(A);
    //     assert(bal == 1500);
    //     vm.prank(A);
    //     // gamebank.buyProperty(2, 60, A);
    //     gamebank.buyProperty(2, A);
    //     uint256 bal1 = gamebank.bal(A);
    //     assert(bal1 == 1440);
    // }

    function testBuyPropertyFromGame() external {
        game = new Game(address(generalNft), address(0), address(players), address(dice), false, 4);
        
        registerPlayers();

        game.addPlayer(player1);
        game.addPlayer(player2);
        game.addPlayer(player3);
        game.addPlayer(player4);

        // vm.prank(A);
        game.startGame();
        address ps1 = players.playerSmartAccount(player1);
        address ps2 = players.playerSmartAccount(player2);
        address ps3 = players.playerSmartAccount(player3);
        address ps4 = players.playerSmartAccount(player4);
        // vm.prank(A);
        game.play(ps1);
        // vm.prank(A);
        game.nextTurn();
        // vm.prank(B);
        game.play(ps2);
        // game.returnPlayer(B);
        uint256 balb4 = game.playersBalances(ps2);
        // vm.prank(B);
        game.buyProperty(ps2);
        MonopolyLibrary.Player memory player22 = game.returnPlayer(ps2);
        MonopolyLibrary.Property memory property22 = game.returnPropertyNft(player22.playerCurrentPosition);
        uint256 balAfter = game.playersBalances(ps2);
        // Confirming change of balance
        assertEq(balAfter, (balb4 - property22.buyAmount));
        // checking new Ownership
        address newOwner = game.getPropertyOwner(player22.playerCurrentPosition);
        assertEq(ps2, newOwner);
        // vm.prank(B);
        game.nextTurn();
        uint256 cbalb4 = game.playersBalances(ps3);
        // vm.prank(C);
        game.play(ps3);
        // game.returnPlayer(C);
        // vm.prank(C);
        vm.expectRevert();  
        game.buyProperty(ps3);

        game.handleRent(ps3);
        MonopolyLibrary.Player memory player33 = game.returnPlayer(ps3);
        MonopolyLibrary.Property memory property22Owned = game.returnPropertyNft(player33.playerCurrentPosition);

        assertEq(game.playersBalances(ps3), (cbalb4 - property22Owned.rentAmount) );
        // uint256 cbalAfter = game.playersBalances(C);
        // assertEq(cbalAfter, cbalb4 - 140);
        // checking new Ownership
        // address cnewOwner = game.getPropertyOwner(12);
        // assertEq(C, cnewOwner);
        // vm.prank(C);
        // game.advanceToNextPlayer();
        // vm.prank(D);
        // game.play();
        // vm.prank(D);
        // game.advanceToNextPlayer();
        // address currentPlayer = game.getCurrentPlayer();
        // // MAKE SURE THE FIRST PLAYER GETS HIS TURN AFTER THE LAST
        // assertEq(currentPlayer, A);
    }

    // function testHandleRent() external {
    //     gamebank.mint(A, 1500);
    //     uint256 bal = gamebank.balanceOf(A);
    //     assert(bal == 1500);
    //     vm.prank(A);
    //     gamebank.buyProperty(13, A);
    //     vm.prank(A);
    //     gamebank.buyProperty(29, A);

    //     // uint256 bal1 = gamebank.bal(A);
    //     // assert(bal1 == 1440);
    //     gamebank.mint(B, 1500);
    //     vm.prank(B);
    //     gamebank.handleRent(B, 13, 5);
    // }

    // function testProposeTradeFromGame() external {
    //     vm.prank(A);
    //     game.startGame();
    //     vm.prank(A);
    //     game.play();
    //     vm.prank(A);
    //     game.advanceToNextPlayer();
    //     vm.prank(B);
    //     game.play();
    //     game.returnPlayer(B);

    //     vm.prank(B);
    //     game.buyProperty(B);
    //     game.returnPlayer(B);

    //     vm.prank(B);
    //     game.advanceToNextPlayer();

    //     vm.prank(C);
    //     game.play();
    //     game.returnPlayer(C);
    //     vm.prank(C);
    //     game.buyProperty(C);

    //     vm.prank(C);
    //     game.advanceToNextPlayer();
    //     vm.prank(D);
    //     game.play();

    //     vm.prank(D);
    //     // game.getProperty(12);
    //     game.openTrade(0, 12, MonopolyLibrary.SwapType.PROPERTY_FOR_CASH, 140, C);

    //     game.returnDeal(C);
    // }

    // function testAcceptTradeP4C() external {
    //     vm.prank(A);
    //     game.startGame();
    //     vm.prank(A);
    //     game.play();
    //     vm.prank(A);
    //     game.advanceToNextPlayer();
    //     vm.prank(B);
    //     game.play();
    //     game.returnPlayer(B);

    //     vm.prank(B);
    //     game.buyProperty();
    //     game.returnPlayer(B);

    //     vm.prank(B);
    //     game.advanceToNextPlayer();

    //     vm.prank(C);
    //     game.play();
    //     game.returnPlayer(C);
    //     vm.prank(C);
    //     game.buyProperty();

    //     vm.prank(C);
    //     game.advanceToNextPlayer();
    //     vm.prank(D);
    //     game.play();

    //     vm.prank(D);
    //     // game.getProperty(12);
    //     game.openTrade(
    //         0,
    //         12,
    //         MonopolyLibrary.SWAP_TYPE.PROPERTY_FOR_CASH,
    //         140,
    //         C
    //     );

    //     game.returnDeal(C);
    //     uint cbalb4 = game.playersBalances(C);

    //     vm.prank(C);
    //     game.acceptTrade();

    //     uint cbalAfter = game.playersBalances(C);

    //     assertEq(cbalAfter, cbalb4 + 140);

    //     console.log("bal b4 ", cbalb4, "Bal after", cbalAfter);

    //     address newOwner = game.getPropertyOwner(12);
    //     assertEq(newOwner, D);
    // }

    // function testAcceptTradeC4P() external {
    //     vm.prank(A);
    //     game.startGame();
    //     vm.prank(A);
    //     game.play();
    //     vm.prank(A);
    //     game.advanceToNextPlayer();
    //     vm.prank(B);
    //     game.play();
    //     game.returnPlayer(B);

    //     vm.prank(B);
    //     game.buyProperty();
    //     game.returnPlayer(B);

    //     vm.prank(B);
    //     game.advanceToNextPlayer();

    //     vm.prank(C);
    //     game.play();
    //     game.returnPlayer(C);
    //     vm.prank(C);
    //     game.buyProperty();

    //     vm.prank(C);
    //     game.advanceToNextPlayer();

    //     vm.prank(D);
    //     game.play();

    //     vm.prank(D);
    //     game.advanceToNextPlayer();

    //     vm.prank(A);
    //     game.play();
    //     vm.prank(A);
    //     game.advanceToNextPlayer();

    //     vm.prank(B);
    //     game.openTrade(
    //         24,
    //         0,
    //         MonopolyLibrary.SWAP_TYPE.CASH_FOR_PROPERTY,
    //         140,
    //         C
    //     );

    //     address ownerB4 = game.getPropertyOwner(24);
    //     uint cbalb4 = game.playersBalances(C);
    //     uint bbalb4 = game.playersBalances(B);

    //     vm.prank(C);
    //     game.acceptTrade();
    //     game.getPropertyOwner(24);

    //     address ownerafter = game.getPropertyOwner(24);
    //     uint bbalAfter = game.playersBalances(B);
    //     uint cbalAfter = game.playersBalances(C);

    //     assertEq(cbalAfter, cbalb4 - 140);
    //     assertEq(bbalAfter, bbalb4 + 140);
    //     assertEq(ownerB4, B);
    //     assertEq(ownerafter, C);

    //     console.log("bal b4  bbalb4", bbalb4, "Bal after bbalAfter", bbalAfter);
    //     console.log("bal b4 ", cbalb4, "Bal after", cbalAfter);
    // }

    // function testAcceptTradeP4P() external {
    //     vm.prank(A);
    //     game.startGame();
    //     vm.prank(A);
    //     game.play();
    //     vm.prank(A);
    //     game.advanceToNextPlayer();
    //     vm.prank(B);
    //     game.play();
    //     game.returnPlayer(B);

    //     vm.prank(B);
    //     game.buyProperty();
    //     game.returnPlayer(B);

    //     vm.prank(B);
    //     game.advanceToNextPlayer();

    //     vm.prank(C);
    //     game.play();
    //     game.returnPlayer(C);
    //     vm.prank(C);
    //     game.buyProperty();

    //     vm.prank(C);
    //     game.advanceToNextPlayer();

    //     vm.prank(D);
    //     game.play();
    //     vm.prank(D);
    //     game.advanceToNextPlayer();

    //     vm.prank(A);
    //     game.play();
    //     vm.prank(A);
    //     game.advanceToNextPlayer();
    //     vm.prank(B);

    //     game.openTrade(
    //         24,
    //         12,
    //         MonopolyLibrary.SWAP_TYPE.PROPERTY_FOR_PROPERTY,
    //         140,
    //         C
    //     );

    //     game.returnDeal(C);
    //     uint cbalb4 = game.playersBalances(C);

    //     vm.prank(C);
    //     game.acceptTrade();

    //     uint cbalAfter = game.playersBalances(C);

    //     assertEq(cbalAfter, cbalb4);

    //     address newOwner = game.getPropertyOwner(12);
    //     assertEq(newOwner, B);

    //     address nwOwner = game.getPropertyOwner(24);
    //     assertEq(nwOwner, C);
    // }

    // function testAcceptTradeP4P$C() external {
    //     vm.prank(A);
    //     game.startGame();
    //     vm.prank(A);
    //     game.play();
    //     vm.prank(A);
    //     game.advanceToNextPlayer();
    //     vm.prank(B);
    //     game.play();
    //     game.returnPlayer(B);

    //     vm.prank(B);
    //     game.buyProperty();
    //     game.returnPlayer(B);

    //     vm.prank(B);
    //     game.advanceToNextPlayer();

    //     vm.prank(C);
    //     game.play();
    //     game.returnPlayer(C);
    //     vm.prank(C);
    //     game.buyProperty();

    //     vm.prank(C);
    //     game.advanceToNextPlayer();

    //     vm.prank(D);
    //     game.play();
    //     vm.prank(D);
    //     game.advanceToNextPlayer();

    //     vm.prank(A);
    //     game.play();
    //     vm.prank(A);
    //     game.advanceToNextPlayer();
    //     vm.prank(B);

    //     game.openTrade(
    //         24,
    //         12,
    //         MonopolyLibrary.SWAP_TYPE.PROPERTY_FOR_CASH_AND_PROPERTY,
    //         140,
    //         C
    //     );

    //     game.returnDeal(C);
    //     uint cbalb4 = game.playersBalances(C);
    //     uint bbalb4 = game.playersBalances(B);

    //     vm.prank(C);
    //     game.acceptTrade();

    //     uint cbalAfter = game.playersBalances(C);
    //     uint bbalAfter = game.playersBalances(B);

    //     assertEq(cbalAfter, (cbalb4 - 140));
    //     assertEq(bbalAfter, (bbalb4 + 140));

    //     console.log("bal b4  ", cbalb4, "Bal after ", cbalAfter);

    //     console.log("bal b4  bbalb4", bbalb4, "Bal after bbalAfter", bbalAfter);

    //     address newOwner = game.getPropertyOwner(12);
    //     assertEq(newOwner, B);

    //     address nwOwner = game.getPropertyOwner(24);
    //     assertEq(nwOwner, C);
    // }

    // function testAcceptTradeP$C4P() external {
    //     vm.prank(A);
    //     game.startGame();
    //     vm.prank(A);
    //     game.play();
    //     vm.prank(A);
    //     game.advanceToNextPlayer();
    //     vm.prank(B);
    //     game.play();
    //     game.returnPlayer(B);

    //     vm.prank(B);
    //     game.buyProperty();
    //     game.returnPlayer(B);

    //     vm.prank(B);
    //     game.advanceToNextPlayer();

    //     vm.prank(C);
    //     game.play();
    //     game.returnPlayer(C);
    //     vm.prank(C);
    //     game.buyProperty();

    //     vm.prank(C);
    //     game.advanceToNextPlayer();

    //     vm.prank(D);
    //     game.play();
    //     vm.prank(D);
    //     game.advanceToNextPlayer();

    //     vm.prank(A);
    //     game.play();
    //     vm.prank(A);
    //     game.advanceToNextPlayer();
    //     vm.prank(B);

    //     game.openTrade(
    //         24,
    //         12,
    //         MonopolyLibrary.SWAP_TYPE.PROPERTY_AND_CASH_FOR_PROPERTY,
    //         140,
    //         C
    //     );

    //     game.returnDeal(C);
    //     uint cbalb4 = game.playersBalances(C);
    //     uint bbalb4 = game.playersBalances(B);

    //     vm.prank(C);
    //     game.acceptTrade();

    //     uint cbalAfter = game.playersBalances(C);
    //     uint bbalAfter = game.playersBalances(B);

    //     assertEq(cbalAfter, (cbalb4 + 140));
    //     assertEq(bbalAfter, (bbalb4 - 140));

    //     console.log("bal b4  ", cbalb4, "Bal after ", cbalAfter);

    //     console.log("bal b4  bbalb4", bbalb4, "Bal after bbalAfter", bbalAfter);

    //     address newOwner = game.getPropertyOwner(12);
    //     assertEq(newOwner, B);

    //     address nwOwner = game.getPropertyOwner(24);
    //     assertEq(nwOwner, C);
    // }

    // function testRejectProposal() external {
    //     vm.prank(A);
    //     game.startGame();
    //     vm.prank(A);
    //     game.play();
    //     vm.prank(A);
    //     game.advanceToNextPlayer();
    //     vm.prank(B);
    //     game.play();
    //     game.returnPlayer(B);

    //     vm.prank(B);
    //     game.buyProperty(B);
    //     game.returnPlayer(B);

    //     vm.prank(B);
    //     game.advanceToNextPlayer();

    //     vm.prank(C);
    //     game.play();
    //     game.returnPlayer(C);
    //     vm.prank(C);
    //     game.buyProperty(C);

    //     vm.prank(C);
    //     game.advanceToNextPlayer();
    //     vm.prank(D);
    //     game.play();

    //     vm.prank(D);
    //     // game.getProperty(12);
    //     game.openTrade(0, 12, MonopolyLibrary.SwapType.PROPERTY_FOR_CASH, 140, C);

    //     vm.prank(C);
    //     game.rejectDeal();

    //     game.returnDeal(C);
    // }

    // function testCounterDeal() external {
    //     vm.prank(A);
    //     game.startGame();
    //     vm.prank(A);
    //     game.play();
    //     vm.prank(A);
    //     game.advanceToNextPlayer();
    //     vm.prank(B);
    //     game.play();
    //     game.returnPlayer(B);

    //     vm.prank(B);
    //     game.buyProperty(B);
    //     game.returnPlayer(B);

    //     vm.prank(B);
    //     game.advanceToNextPlayer();

    //     vm.prank(C);
    //     game.play();
    //     game.returnPlayer(C);
    //     vm.prank(C);
    //     game.buyProperty(C);

    //     vm.prank(C);
    //     game.advanceToNextPlayer();
    //     vm.prank(D);
    //     game.play();

    //     vm.prank(D);

    //     game.openTrade(0, 12, MonopolyLibrary.SwapType.PROPERTY_FOR_CASH, 140, C);

    //     game.returnDeal(C);

    //     vm.prank(C);
    //     game.counterDeal(0, 12, MonopolyLibrary.SwapType.CASH_FOR_PROPERTY, 200);

    //     game.returnDeal(D);
    // }
}
