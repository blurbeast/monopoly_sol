// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {GameBank} from "../src/Bank.sol";
import {Game} from "../src/Game.sol";
import {GeneralNFT} from "../src/NFT.sol";
import "../src/libraries/MonopolyLibrary.sol";
import {PlayerS} from "../src/Players.sol";
import {Dice} from "../src/Dice.sol";

using MonopolyLibrary for MonopolyLibrary.Property;
using MonopolyLibrary for MonopolyLibrary.PropertyColors;
using MonopolyLibrary for MonopolyLibrary.PropertyType;

struct Player {
    string username;
    address addr;
    uint8 playerCurrentPosition;
    bool inJail;
    uint8 jailAttemptCount;
    uint256 totalPlayersWorth;
}

contract MonopolyTest is Test {
    GameBank public gamebank;
    Game public game;
    GeneralNFT public generalNft;
    PlayerS public playerS;
    Dice public dice;

    address A = address(0xa);
    address B = address(0xb);
    address C = address(0xc);
    address D = address(0xd);

    address E = address(0xe);

    address[] allGamePlayers = [A, B, C, D];

    function setUp() public {
        // Deploy contracts
        dice = new Dice();
        generalNft = new GeneralNFT("uri");
        playerS = new PlayerS();
        _registerPlayers();
        gamebank = new GameBank(4, address(generalNft));
        game = new Game(address(generalNft), allGamePlayers, address(playerS), address(dice));

        // Log initial states for debugging
        console.log("GeneralNFT deployed at:", address(generalNft));
        console.log("GameBank deployed at:", address(gamebank));
        // console.log("Game deployed at:", address(game));
    }

    function _registerPlayers() private {
        playerS.registerPlayer(A, "Alice");
        playerS.registerPlayer(B, "Bob");
        playerS.registerPlayer(C, "Charlie");
        playerS.registerPlayer(D, "David");
    }

    function testPlayGame() external {
        // player cannot play game when the game has not yet started 
        vm.expectRevert("Game not started yet");
        game.play(A);

        // game has started
        game.startGame();

        // the first player to player is the player at index zero 
        // confirm that 
        vm.expectRevert("Not your turn");
        game.play(B);

        //play game now 
        address currentPlayer = game.getCurrentPlayer();
        assertEq(currentPlayer, A);
        game.play(A);

        //zafter play, the turn should move to the next player 
        game.nextTurn();

        //check that the next player is the player at index 1
        address nextPlayer = game.getCurrentPlayer();

        assertEq(nextPlayer, B);
    }

    function testPlayGames() external {
        //startgame 
        game.startGame();
        // play game 
        game.play(A);

        // run three turns 
        game.nextTurn();
        game.nextTurn();
        game.nextTurn();

        address nextPlayer = game.getCurrentPlayer();
        assertEq(nextPlayer, D);

        //next turn move to the first player
        game.nextTurn();

        address currentPlayer = game.getCurrentPlayer();
        assertEq(currentPlayer, A);
    }

    function testHandleRentAndProperty() external {
        //start game 
        game.startGame();

        //start game 
        game.play(A);

        vm.expectRevert("Property does not have an owner");
        game.handleRent(A);

        //buy property
        game.buyProperty(A);

        MonopolyLibrary.Player memory player = game.returnPlayer(A);

        //get property
        


    }
    // function testSetupContracts() public view {
    //     // Check if the contracts are correctly deployed
    //     assert(address(generalNft) != address(0));
    //     assert(address(gamebank) != address(0));
    //     // assert(address(game) != address(0));
    // }

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

    // function testBuyPropertyFromGame() external {
    //     vm.prank(A);
    //     game.startGame();
    //     vm.prank(A);
    //     game.play();
    //     vm.prank(A);
    //     game.advanceToNextPlayer();
    //     vm.prank(B);
    //     game.play();
    //     game.returnPlayer(B);
    //     uint256 balb4 = game.playersBalances(B);
    //     // vm.prank(B);
    //     // game.buyProperty(B);
    //     // game.returnPlayer(B);
    //     // uint256 balAfter = game.playersBalances(B);
    //     // Confirming change of balance
    //     // assertEq(balAfter, balb4 - 220);
    //     // checking new Ownership
    //     // address newOwner = game.getPropertyOwner(24);
    //     // assertEq(B, newOwner);
    //     vm.prank(B);
    //     game.advanceToNextPlayer();
    //     uint256 cbalb4 = game.playersBalances(C);
    //     vm.prank(C);
    //     game.play();
    //     game.returnPlayer(C);
    //     vm.prank(C);
    //     // game.buyProperty(C);
    //     // uint256 cbalAfter = game.playersBalances(C);
    //     // assertEq(cbalAfter, cbalb4 - 140);
    //     // checking new Ownership
    //     // address cnewOwner = game.getPropertyOwner(12);
    //     // assertEq(C, cnewOwner);
    //     // vm.prank(C);
    //     // game.advanceToNextPlayer();
    //     // vm.prank(D);
    //     // game.play();
    //     // vm.prank(D);
    //     // game.advanceToNextPlayer();
    //     // address currentPlayer = game.getCurrentPlayer();
    //     // // MAKE SURE THE FIRST PLAYER GETS HIS TURN AFTER THE LAST
    //     // assertEq(currentPlayer, A);
    // }

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
