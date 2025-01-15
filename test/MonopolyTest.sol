// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {GameBank} from "../src/Bank.sol";
import {Game} from "../src/Game.sol";
import {GeneralNFT} from "../src/NFT.sol";
import "../src/libraries/MonopolyLibrary.sol";

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

    address A = address(0xa);
    address B = address(0xb);
    address C = address(0xc);
    address D = address(0xd);

    address E = address(0xe);

    address[] a = [A, B, C, D];

    function setUp() public {
        // Deploy contracts
        generalNft = new GeneralNFT("uri");

        gamebank = new GameBank(4, address(generalNft));
        game = new Game(address(generalNft), a);

        // Log initial states for debugging
        console.log("GeneralNFT deployed at:", address(generalNft));
        console.log("GameBank deployed at:", address(gamebank));
        // console.log("Game deployed at:", address(game));
    }

    function testSetupContracts() public view {
        // Check if the contracts are correctly deployed
        assert(address(generalNft) != address(0));
        assert(address(gamebank) != address(0));
        // assert(address(game) != address(0));
    }

    function testBuyPropertyFromBank() external {
        gamebank.mint(A, 1500);
        uint256 bal = gamebank.bal(A);
        assert(bal == 1500);
        vm.prank(A);
        gamebank.buyProperty(2, 60, A);
        uint256 bal1 = gamebank.bal(A);
        assert(bal1 == 1440);
    }

    function testBuyPropertyFromGame() external {
        vm.prank(A);
        game.startGame();
        vm.prank(A);
        game.play();
        vm.prank(A);
        game.advanceToNextPlayer();
        vm.prank(B);
        game.play();
        uint balb4 = game.playersBalances(B);
        vm.prank(B);
        game.buyProperty(24, 220);
        game.returnPlayer(B);
        uint balAfter = game.playersBalances(B);
        assertEq(balAfter, balb4 - 220);
    }
}
