// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {GameBank} from "../src/Bank.sol";
import {Game} from "../src/Game.sol";
import {GeneralNFT} from "../src/NFT.sol";

struct Property {
    bytes name;
    uint256 rentAmount;
    bytes uri;
    uint256 buyAmount;
    PropertyType propertyType;
    PropertyColors color;
}

enum PropertyType {
    Property,
    RailStation,
    Utility,
    Special
}

enum PropertyColors {
    PINK,
    YELLOW,
    BLUE,
    ORANGE,
    RED,
    GREEN,
    PURPLE,
    BROWN
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
        // game = new Game(address(generalNft), a);

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

    function testBuyPropertyFromBank(uint8 propertyId) external {
        gamebank.mint(A, 1500);
        uint256 bal = gamebank.bal(A);
        assert(bal == 1500);
        vm.prank(A);
        gamebank.buyProperty(2, 60);
        uint256 bal1 = gamebank.bal(A);
        assert(bal1 == 1440);

        gamebank.mint(B, 1500);
        vm.prank(B);
        gamebank.buyProperty(2, 60);
        vm.prank(A);
        gamebank.sellProperty(2);
        gamebank.gameProperties(2);
    }
}
