// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "../src/libraries/MonopolyLibrary.sol";
import {GameBank} from "../src/Bank.sol";
import {GeneralNFT} from "../src/NFT.sol";
import { GameToken } from "../src/GameToken.sol";
import {Test, console} from "forge-std/Test.sol";

// this is the test contract to test all of the functionalities of the bank contract in the source file

contract BankTest is Test {
    GameBank private gameBank;
    GeneralNFT private generalNft;
    address private player1 = address(0xa);
    address private player2 = address(0xb);
    GameToken private gameToken;
//
    function setUp() public {
        generalNft = new GeneralNFT("");
        gameToken = new GameToken();
        gameBank = new GameBank(4, address(generalNft), address (gameToken));
    }
//
//    // upon deployment , the balance of the bank should be 8
    function testBankBalance() external view {
        address bankAddress = address(gameBank);
        uint256 bankBalance = gameToken.balanceOf(bankAddress, bankAddress );
        assertEq(bankBalance, 8000);
        MonopolyLibrary.PropertyG memory property = gameBank.getProperty(1);
        address _owner = property.owner;
        assertEq(_owner, address(address(gameBank)));
        assertEq(string(property.name), "GO");
    }
//
    function testBuyProperty() external {
        // to buy property , there must be a player
        // the player must hold the bank token
        address bankAddress = address(gameBank);
        address[] memory players = new address[](2);
        players[0] = (player1);
        players[1] = (player2);
        gameBank.mints(players, 1500);
        // be sure player has a token of the bank
        assertEq(gameToken.balanceOf(player1, bankAddress), 1500);
        assertEq(gameToken.balanceOf(bankAddress, bankAddress ), 5000);
        //        console.log("log is ::: ",gameBank.totalSupply());

        // allow bank to perform transaction on behalf of player
        gameToken.approve(bankAddress, player1, bankAddress);
        //buy property
        gameBank.buyProperty(2, player1);
        MonopolyLibrary.PropertyG memory property = gameBank.getProperty(2);

        assertEq(player1, property.owner);
        gameBank.buyProperty(6, player1);

        MonopolyLibrary.PropertyColors color = property.propertyColor;
        assertEq(uint8(color), uint8(MonopolyLibrary.PropertyColors.BROWN));

        uint8 result = gameBank.getNumberOfUserOwnedPropertyOnAColor(player1, MonopolyLibrary.PropertyColors.PURPLE);

        assertEq(result, 1);

        assert(gameToken.balanceOf(player1, bankAddress) == 1240);

        assertEq(gameToken.balanceOf(address(gameBank), bankAddress), 5260);

        // test that the number of user property color is one
    }
//
//    // test that user can pay rent
    function testHandleRent() external {

        address bankAddress = address (gameBank);
        address[] memory players = new address[](2);
        players[0] = (player1);
        players[1] = (player2);
        gameBank.mints(players, 1500);
        // special property cannot be rented
        vm.expectRevert();
        gameBank.handleRent(player2, 1, 2);

        vm.expectRevert();
        gameBank.handleRent(player1, 2, 4);
        //        gameBank.mint(player2, 1000);
        //        gameBank.mint(player1, 1000);
        gameToken.approve(bankAddress, player2, bankAddress);
        gameToken.approve(bankAddress, player1, bankAddress);
        gameBank.buyProperty(2, player2); // 1440

        vm.expectRevert();
        gameBank.buyProperty(2, player2);

        // player to pay for rent
        vm.expectRevert();
        gameBank.handleRent(player2, 2, 6);

        gameBank.handleRent(player1, 2, 5); //1498

        assertEq(gameToken.balanceOf(player1, bankAddress), 1498);

        assertEq(gameToken.balanceOf(player2, bankAddress), 1442);
    }
//
//    // test rent for different property types
    function testHandleRentA() external {
        //        gameBank.mint(player2, 2000);
        //        gameBank.mint(player1, 2000);
        address bankAddress = address (gameBank);
        address[] memory players = new address[](2);
        players[0] = (player1);
        players[1] = (player2);
        gameBank.mints(players, 1500);
        // rail station
        gameToken.approve(bankAddress, player2, bankAddress);
        gameToken.approve(bankAddress, player1, bankAddress);

        gameBank.buyProperty(16, player1); //200
        gameBank.buyProperty(26, player2); //200
        gameBank.buyProperty(36, player1); //200
        gameBank.buyProperty(6, player1); //200

        //utility
        gameBank.buyProperty(29, player2); //150
        gameBank.buyProperty(13, player2); //150

        // for utility for just one property owned by a user
        gameBank.handleRent(player1, 29, 10);

        assertEq(gameToken.balanceOf(player1, bankAddress), 800);
        assertEq(gameToken.balanceOf(player2, bankAddress), 1100);

        // for rail station
        gameBank.handleRent(player2, 16, 4);

        assertEq(gameToken.balanceOf(player2, bankAddress), 1000);
        assertEq(gameToken.balanceOf(player1, bankAddress), 900);
    }
//
    function testUpgradeAndDowngradeProperty() external {
        //        gameBank.mint(player1, 2000);

        address bankAddress = address (gameBank);
        address[] memory players = new address[](2);
        players[0] = (player1);
        players[1] = (player2);
        gameBank.mints(players, 1500);
        gameToken.approve(bankAddress, player1, bankAddress);
        gameToken.approve(bankAddress, player2, bankAddress);
        gameBank.buyProperty(2, player1); //60
        MonopolyLibrary.PropertyG memory property = gameBank.getProperty(2);
        assertEq(property.noOfUpgrades, 0);

        vm.startPrank(player1);
        vm.expectRevert();
        gameBank.upgradeProperty(2, 3, player1);

        gameBank.buyProperty(4, player1); //80

        gameBank.upgradeProperty(2, 3, player1);

        vm.stopPrank();

        // another user cannot upgrade another player property
        vm.startPrank(player2);
        vm.expectRevert();
        gameBank.upgradeProperty(2, 3, player2);
        vm.stopPrank();

        MonopolyLibrary.PropertyG memory afterUpgradeProperty = gameBank.getProperty(2);

        assertEq(afterUpgradeProperty.noOfUpgrades, 3);

        assertEq(gameToken.balanceOf(player1, bankAddress), 880);

        vm.startPrank(player1);
        vm.expectRevert();
        gameBank.upgradeProperty(2, 3, player1);
        //        vm.stopPrank();

        vm.expectRevert();
        gameBank.downgradeProperty(2, 4, player1);

        // downgrade property
        gameBank.downgradeProperty(2, 3, player1);

        assertEq(gameToken.balanceOf(player1, bankAddress), 1120);

        MonopolyLibrary.PropertyG memory afterDowngradeProperty = gameBank.getProperty(2);

        assertEq(afterDowngradeProperty.noOfUpgrades, 0);
    }
//
    function testMortgageAndReleaseProperty() external {
        //        gameBank.mint(player1, 2000);

        //        vm.expectRevert();
        //        gameBank.buyProperty(2, player2);

        address bankAddress = address (gameBank);
        address[] memory players = new address[](2);
        players[0] = (player1);
        players[1] = (player2);
        gameBank.mints(players, 1500);

        gameToken.approve(bankAddress, player1, bankAddress);
        gameToken.approve(bankAddress, player2, bankAddress);

        vm.startPrank(player1);
        gameBank.buyProperty(2, player1); //60

        //player1 balance should be 1940 as the property amount is 60

        gameBank.mortgageProperty(2, player1);

        assertEq(gameToken.balanceOf(player1, bankAddress), 1470);

        vm.expectRevert();
        gameBank.mortgageProperty(2, player1);

        // no action can be performed on a mortgaged property
        vm.expectRevert();
        gameBank.upgradeProperty(2, 3, player1);

        gameBank.releaseMortgage(2, player1);

        assertEq(gameToken.balanceOf(player1, bankAddress), 1440);

        vm.stopPrank();
    }
//
    function testHandleRentsWIthNumberOfUpgrade() external {
        address bankAddress = address (gameBank);
        address[] memory players = new address[](2);
        players[0] = (player1);
        players[1] = (player2);
        gameBank.mints(players, 1500);

        gameToken.approve(bankAddress, player1, bankAddress);
        gameToken.approve(bankAddress, player2, bankAddress);


    vm.startPrank(player1);
        gameBank.buyProperty(2, player1);
        gameBank.buyProperty(4, player1);

        gameBank.upgradeProperty(2, 3, player1);

        vm.startPrank(player2);
        gameBank.handleRent(player2, 2, 10);

        assertEq(gameToken.balanceOf(player2, bankAddress), 1492);
    }
//
//    function testProposal() external {
//
//        address bankAddress = address (gameBank);
//        address[] memory players = new address[](2);
//        players[0] = (player1);
//        players[1] = (player2);
//        gameBank.mints(players, 1500);
//
//        gameToken.approve(bankAddress, player1, bankAddress);
//        gameToken.approve(bankAddress, player2, bankAddress);
//
//        // test that user can only propose owned asset;
//        MonopolyLibrary.SwapType swapType = MonopolyLibrary.SwapType.PROPERTY_FOR_CASH;
//        vm.expectRevert("asset specified is not owned by player");
//        gameBank.makeProposal(player1, player2, 2, 6, swapType, 0);
//
//        gameBank.buyProperty(2, player1);
//
//        // mortgaged asset cannot be used as proposal
//        gameBank.mortgageProperty(2, player1);
//
//        vm.expectRevert("asset on mortgage");
//        gameBank.makeProposal(player1, player2, 2, 6, swapType, 0);
//
//        gameBank.buyProperty(6, player2);
//
//        gameBank.releaseMortgage(2, player1);
//        MonopolyLibrary.SwapType swappedType = MonopolyLibrary.SwapType.PROPERTY_FOR_PROPERTY;
//        gameBank.makeProposal(player1, player2, 2, 6, swappedType, 0);
//
////        (,, MonopolyLibrary.SwapType _swap, MonopolyLibrary.ProposalStatus status) = gameBank.inGameProposals(1);
////        //
////        assertEq(uint8(_swap), uint8(MonopolyLibrary.SwapType.PROPERTY_FOR_PROPERTY));
////
////        MonopolyLibrary.SwappedType memory swappedTypes = gameBank.getProposalSwappedType(1);
////
////        assertEq(swappedTypes.propertyForProperty.biddingPropertyId, 6);
////
////        assertEq(uint8(status), 0);
////
////        (uint8 noOfOwnedBefore) = gameBank.noOfColorGroupOwnedByUser(MonopolyLibrary.PropertyColors.BROWN, player1);
////        assertEq(noOfOwnedBefore, 1);
////        // accept proposal
////        gameBank.makeDecisionOnProposal(player2, 1, true);
////
////        (,, MonopolyLibrary.SwapType _swapp, MonopolyLibrary.ProposalStatus statuss) = gameBank.inGameProposals(1);
////
////        assertEq(uint8(statuss), 1);
////
////        assertEq(uint8(_swapp), 0);
//
////        (address previouslyOwnedByPlayer1) = gameBank.propertyOwner(2);
////        (address previouslyOwnedByPlayer2) = gameBank.propertyOwner(6);
//
//        assertEq(previouslyOwnedByPlayer1, player2);
//        assertEq(previouslyOwnedByPlayer2, player1);
//
//        (uint8 noOfOwnedAfter) = gameBank.noOfColorGroupOwnedByUser(MonopolyLibrary.PropertyColors.BROWN, player1);
//
//        (,,,, address getOwner,,,) = gameBank.gameProperties(6);
//
//        assertEq(noOfOwnedAfter, 0);
//
//        assertEq(getOwner, player1);
//
//        // proposal cannot be accepted more than once
//
//        vm.expectRevert();
//        gameBank.makeDecisionOnProposal(player2, 1, true);
//    }
//
    function testGetPropertiesOwnerByAPlayer() external {

        address bankAddress = address (gameBank);
        address[] memory players = new address[](2);
        players[0] = (player1);
        players[1] = (player2);
        gameBank.mints(players, 1500);

        gameToken.approve(bankAddress, player1, bankAddress);
        gameToken.approve(bankAddress, player2, bankAddress);


    gameBank.buyProperty(2, player1);
        gameBank.buyProperty(6, player1);
        gameBank.buyProperty(7, player2);
        gameBank.buyProperty(10, player2);
        gameBank.buyProperty(16, player1);
        gameBank.buyProperty(17, player1);

        MonopolyLibrary.PropertyG[] memory playerOwnedProperties = gameBank.getPropertiesOwnedByAPlayer(player1);

        assertEq(playerOwnedProperties.length, 4);

        MonopolyLibrary.PropertyG memory property = playerOwnedProperties[0];
        assertEq(property.name, bytes("Mediterranean Avenue"));
    }
}
