// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "../src/libraries/MonopolyLibrary.sol";
import {GameBank} from "../src/Bank.sol";
import {GeneralNFT} from "../src/NFT.sol";
import {Test, console} from "forge-std/Test.sol";

// this is the test contract to test all of the functionalities of the bank contract in the source file

contract BankTest is Test {
    GameBank private gameBank;
    GeneralNFT private generalNft;
    address private player1 = address(0xa);
    address private player2 = address(0xb);

    function setUp() public {
        generalNft = new GeneralNFT("");
        gameBank = new GameBank(4, address(generalNft));
        gameBank.mint(player1, 2000);
        gameBank.mint(player2, 2000);
    }

    // upon deployment , the balance of the bank should be 8
    function testBankBalance() external view {
        uint256 bankBalance = gameBank.balanceOf(address(gameBank));
        assertEq(bankBalance, 4000);
        MonopolyLibrary.PropertyG memory property = gameBank.getProperty(1);
        address _owner = property.owner;
        assertEq(_owner, address(address(gameBank)));
        assertEq(string(property.name), "GO");
    }

    function testBuyProperty() external {
        // to buy property , there must be a player
        // the player must hold the bank token

        // be sure player has a token of the bank
        assertEq(gameBank.balanceOf(player1), 2000);
        assertEq(gameBank.balanceOf(address(gameBank)), 4000);
        //        console.log("log is ::: ",gameBank.totalSupply());

        //buy property
        gameBank.buyProperty(2, player1);
        MonopolyLibrary.PropertyG memory property = gameBank.getProperty(2);

        assertEq(player1, property.owner);
        gameBank.buyProperty(6, player1);

        MonopolyLibrary.PropertyColors color = property.propertyColor;
        assertEq(uint8(color), uint8(MonopolyLibrary.PropertyColors.BROWN));

        uint8 result = gameBank.getNumberOfUserOwnedPropertyOnAColor(
            player1,
            MonopolyLibrary.PropertyColors.PURPLE
        );

        assertEq(result, 1);

        assert(gameBank.balanceOf(player1) == 1740);

        assertEq(gameBank.balanceOf(address(gameBank)), 4260);

        // test that the number of user property color is one
    }

    function testMakingProposals() external {
        // to buy property , there must be a player
        // the player must hold the bank token

        // be sure player has a token of the bank
        assertEq(gameBank.balanceOf(player1), 2000);
        assertEq(gameBank.balanceOf(player2), 2000);

        assertEq(gameBank.balanceOf(address(gameBank)), 4000);
        //        console.log("log is ::: ",gameBank.totalSupply());

        //buy property
        gameBank.buyProperty(2, player1);

        gameBank.getProperty(2);

        gameBank.buyProperty(6, player2);

        gameBank.getProperty(6);

        vm.prank(player1);

        address owner = gameBank.getPropertyOwner(2);

        assertEq(owner, player1);

        gameBank.makeProposal(
            player1,
            player2,
            2,
            6,
            MonopolyLibrary.SwapType.CASH_FOR_PROPERTY,
            200
        );

        gameBank.inGameProposalss(player2);

        uint bal1b4 = gameBank.balanceOf(player1);
        uint bal2b4 = gameBank.balanceOf(player2);
        vm.prank(player2);

        gameBank.acceptProposal(player2);

        uint bal1after = gameBank.balanceOf(player1);
        uint bal2after = gameBank.balanceOf(player2);

        console.log("bal1 before", bal1b4, "Bal1 after", bal1after);

        console.log("bal2 before", bal2b4, "Bal2 after", bal2after);

        // address newOwner = gameBank.getPropertyOwner(6);
        // assertEq(newOwner, player2);
        // assert(owner != newOwner);

        gameBank.getProperty(6);
    }
    //     // test that user can pay rent
    //     function testHandleRent() external {
    //         // special property cannot be rented
    //         vm.expectRevert();
    //         gameBank.handleRent(player2, 1, 2);

    //         vm.expectRevert();
    //         gameBank.handleRent(player1, 2, 4);
    //         //        gameBank.mint(player2, 1000);
    //         //        gameBank.mint(player1, 1000);
    //         gameBank.buyProperty(2, player2);

    //         vm.expectRevert();
    //         gameBank.buyProperty(2, player2);

    //         // player to pay for rent
    //         vm.expectRevert();
    //         gameBank.handleRent(player2, 2, 6);

    //         gameBank.handleRent(player1, 2, 5);

    //         assertEq(gameBank.balanceOf(player1), 1998);

    //         assertEq(gameBank.balanceOf(player2), 1942);
    //     }

    //     // test rent for different property types
    //     function testHandleRentA() external {
    //         //        gameBank.mint(player2, 2000);
    //         //        gameBank.mint(player1, 2000);

    //         // rail station
    //         gameBank.buyProperty(16, player1); //200
    //         gameBank.buyProperty(26, player2); //200
    //         gameBank.buyProperty(36, player1); //200
    //         gameBank.buyProperty(6, player1); //200

    //         //utility
    //         gameBank.buyProperty(29, player2); //150
    //         gameBank.buyProperty(13, player2); //150

    //         // for utility for just one property owned by a user
    //         gameBank.handleRent(player1, 29, 10);

    //         assertEq(gameBank.balanceOf(player1), 1300);
    //         assertEq(gameBank.balanceOf(player2), 1600);

    //         // for rail station
    //         gameBank.handleRent(player2, 16, 4);

    //         assertEq(gameBank.balanceOf(player2), 1500);
    //         assertEq(gameBank.balanceOf(player1), 1400);
    //     }

    //     function testUpgradeAndDowngradeProperty() external {
    //         //        gameBank.mint(player1, 2000);

    //         gameBank.buyProperty(2, player1); //60
    //         MonopolyLibrary.PropertyG memory property = gameBank.getProperty(2);
    //         assertEq(property.noOfUpgrades, 0);

    //         vm.startPrank(player1);
    //         vm.expectRevert();
    //         gameBank.upgradeProperty(2, 3, player1);

    //         gameBank.buyProperty(4, player1); //80

    //         gameBank.upgradeProperty(2, 3, player1);

    //         vm.stopPrank();

    //         // another user cannot upgrade another player property
    //         vm.startPrank(player2);
    //         vm.expectRevert();
    //         gameBank.upgradeProperty(2, 3, player2);
    //         vm.stopPrank();

    //         MonopolyLibrary.PropertyG memory afterUpgradeProperty = gameBank
    //             .getProperty(2);

    //         assertEq(afterUpgradeProperty.noOfUpgrades, 3);

    //         assertEq(gameBank.balanceOf(player1), 1380);

    //         vm.startPrank(player1);
    //         vm.expectRevert();
    //         gameBank.upgradeProperty(2, 3, player1);
    //         //        vm.stopPrank();

    //         vm.expectRevert();
    //         gameBank.downgradeProperty(2, 4, player1);

    //         // downgrade property
    //         gameBank.downgradeProperty(2, 3, player1);

    //         assertEq(gameBank.balanceOf(player1), 1620);

    //         MonopolyLibrary.PropertyG memory afterDowngradeProperty = gameBank
    //             .getProperty(2);

    //         assertEq(afterDowngradeProperty.noOfUpgrades, 0);
    //     }

    //     function testMortgageAndReleaseProperty() external {
    //         //        gameBank.mint(player1, 2000);

    //         //        vm.expectRevert();
    //         //        gameBank.buyProperty(2, player2);

    //         vm.startPrank(player1);
    //         gameBank.buyProperty(2, player1); //60

    //         //player1 balance should be 1940 as the property amount is 60

    //         gameBank.mortgageProperty(2, player1);

    //         assertEq(gameBank.balanceOf(player1), 1970);

    //         vm.expectRevert();
    //         gameBank.mortgageProperty(2, player1);

    //         // no action can be performed on a mortgaged property
    //         vm.expectRevert();
    //         gameBank.upgradeProperty(2, 3, player1);

    //         gameBank.releaseMortgage(2, player1);

    //         assertEq(gameBank.balanceOf(player1), 1940);

    //         vm.stopPrank();
    //     }

    //     function testHandleRentsWIthNumberOfUpgrade() external {
    //         vm.startPrank(player1);
    //         gameBank.buyProperty(38, player1);
    //         gameBank.buyProperty(40, player1);

    //         // gameBank.mint(player1, 4000);
    //         gameBank.upgradeProperty(40, 5, player1);
    //         uint balb4 = gameBank.balanceOf(player1);

    //         gameBank.downgradeProperty(40, 1, player1);
    //         uint balAfter = gameBank.balanceOf(player1);
    //         gameBank.getProperty(40);

    //         console.log("b4 ", balb4, "after ", balAfter);
    //         // vm.startPrank(player2);
    //         // gameBank.handleRent(player2, 2, 10);

    //         // assertEq(gameBank.balanceOf(player2), 1992);
    //     }

    //     function testProposal() external {
    //         // test that user can only propose owned asset;
    //         MonopolyLibrary.SwapType swapType = MonopolyLibrary
    //             .SwapType
    //             .PROPERTY_FOR_CASH;
    //         vm.expectRevert("asset specified is not owned by player");
    //         gameBank.makeProposal(player1, player2, 2, 6, swapType, 0);

    //         gameBank.buyProperty(2, player1);

    //         // mortgaged asset cannot be used as proposal
    //         gameBank.mortgageProperty(2, player1);

    //         vm.expectRevert("asset on mortgage");
    //         gameBank.makeProposal(player1, player2, 2, 6, swapType, 0);

    //         gameBank.buyProperty(6, player2);

    //         gameBank.releaseMortgage(2, player1);
    //         MonopolyLibrary.SwapType swappedType = MonopolyLibrary
    //             .SwapType
    //             .PROPERTY_FOR_PROPERTY;
    //         gameBank.makeProposal(player1, player2, 2, 6, swappedType, 0);

    //         (
    //             ,
    //             ,
    //             MonopolyLibrary.SwapType _swap,
    //             MonopolyLibrary.ProposalStatus status
    //         ) = gameBank.inGameProposals(1);
    //         //
    //         assertEq(
    //             uint8(_swap),
    //             uint8(MonopolyLibrary.SwapType.PROPERTY_FOR_PROPERTY)
    //         );

    //         MonopolyLibrary.SwappedType memory swappedTypes = gameBank
    //             .getProposalSwappedType(1);

    //         assertEq(swappedTypes.propertyForProperty.biddingPropertyId, 6);

    //         assertEq(uint8(status), 0);

    //         uint8 noOfOwnedBefore = gameBank.noOfColorGroupOwnedByUser(
    //             MonopolyLibrary.PropertyColors.BROWN,
    //             player1
    //         );
    //         assertEq(noOfOwnedBefore, 1);
    //         // accept proposal
    //         gameBank.makeDecisionOnProposal(player2, 1, true);

    //         (
    //             ,
    //             ,
    //             MonopolyLibrary.SwapType _swapp,
    //             MonopolyLibrary.ProposalStatus statuss
    //         ) = gameBank.inGameProposals(1);

    //         assertEq(uint8(statuss), 1);

    //         address previouslyOwnedByPlayer1 = gameBank.propertyOwner(2);
    //         address previouslyOwnedByPlayer2 = gameBank.propertyOwner(6);

    //         assertEq(previouslyOwnedByPlayer1, player2);
    //         assertEq(previouslyOwnedByPlayer2, player1);

    //         uint8 noOfOwnedAfter = gameBank.noOfColorGroupOwnedByUser(
    //             MonopolyLibrary.PropertyColors.BROWN,
    //             player1
    //         );

    //         (, , , , address getOwner, , , ) = gameBank.gameProperties(6);

    //         assertEq(noOfOwnedAfter, 0);

    //         assertEq(getOwner, player1);
    //     }
}
