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

    function testCreateProposalFromBank() external {
        gamebank.mint(A, 1500);
        gamebank.mint(B, 1500);
        // uint256 bal = gamebank.bal(A);

        vm.prank(A);
        gamebank.buyProperty(2, A);

        vm.prank(B);
        gamebank.buyProperty(25, B);

        uint256 balAB4 = gamebank.bal(A);
        uint256 balB4 = gamebank.bal(B);

        vm.prank(B);
        gamebank.proposePropertySwap(B, A, 25, 2, MonopolyLibrary.SwapType.PROPERTY_AND_CASH_FOR_PROPERTY, 50);

        vm.prank(A);
        gamebank.viewDeals(A);

        vm.prank(A);
        gamebank.acceptDeal(A);

        uint256 balA = gamebank.bal(A);
        uint256 bal = gamebank.bal(B);

        console.log("bal A before:", balAB4, "  bal B after: ", balA);
        console.log("bal Before:", balB4, "  bal B after: ", bal);

        gamebank.getPropertyOwner(2);
        gamebank.getPropertyOwner(25);
    }

    function testMortgageProperty() external {
        vm.prank(A);
        game.startGame();
        vm.prank(A);
        game.play();
        vm.prank(A);
        game.advanceToNextPlayer();
        vm.prank(B);
        game.play();
        game.returnPlayer(B);

        vm.prank(B);
        game.buyProperty();
        game.returnPlayer(B);

        vm.prank(B);
        game.advanceToNextPlayer();

        vm.prank(C);
        game.play();
        game.returnPlayer(C);
        vm.prank(C);
        game.buyProperty();

        vm.prank(C);
        game.advanceToNextPlayer();

        vm.prank(D);
        game.play();
        vm.prank(D);
        game.advanceToNextPlayer();

        vm.prank(A);
        game.play();
        vm.prank(A);
        game.advanceToNextPlayer();

        vm.prank(B);
        game.mortgageProperty(24);

        vm.prank(B);
        game.releaseMortgage(24);

        vm.prank(B);

        game.openTrade(
            24,
            12,
            MonopolyLibrary.SwapType.PROPERTY_FOR_PROPERTY,
            140,
            C
        );

        game.returnDeal(C);
        uint cbalb4 = game.playersBalances(C);

        vm.prank(C);
        game.acceptTrade();

        uint cbalAfter = game.playersBalances(C);

        assertEq(cbalAfter, cbalb4);

        address newOwner = game.getPropertyOwner(12);
        assertEq(newOwner, B);

        address nwOwner = game.getPropertyOwner(24);
        assertEq(nwOwner, C);
    }

    function testUpgradeAndDowngradePropertyFromBank() external {
        gamebank.mint(A, 1500);
        gamebank.mint(B, 6500);

        vm.prank(A);
        gamebank.buyProperty(2, A);

        vm.prank(B);
        gamebank.buyProperty(27, B);
        gamebank.buyProperty(28, B);
        gamebank.buyProperty(30, B);

        vm.prank(B);
        gamebank.upgradeProperty(27, 4, B);

        uint initialBalance = gamebank.balanceOf(B);
        vm.prank(B);
        gamebank.downgradeProperty(27, 3, B);
        uint balanceAfterUpgrade = gamebank.balanceOf(B);
        gamebank.getProperty(27);

        console.log(
            "initial Balance",
            initialBalance,
            "balance After downgrade",
            balanceAfterUpgrade
        );
    }

    // COMMENT LINE 593 IN Bank.sol
//    function testUpgradeAndDowngradePropertyFromGame() external {
//        game.startGame();
//
//        game.updateProperty(27, A);
//        game.updateProperty(28, A);
//        game.updateProperty(30, A);
//
//        vm.prank(A);
//        game.upgradeProperty(30, 2);
//
//        uint initialBalance = game.playersBalances(A);
//
//        vm.prank(A);
//        game.downgradeProperty(30, 1);
//
//        game.getProperty(30);
//
//        uint balanceAfterUpgrade = game.playersBalances(A);
//
//        console.log(
//            "initial Balance",
//            initialBalance,
//            "balance After upgrade",
//            balanceAfterUpgrade
//        );
//    }
}
