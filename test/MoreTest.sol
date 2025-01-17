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
        gamebank.proposePropertySwap(B, A, 25, 2, MonopolyLibrary.SWAP_TYPE.PROPERTY_AND_CASH_FOR_PROPERTY, 50);

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
}
