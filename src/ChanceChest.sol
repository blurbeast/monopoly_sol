pragma solidity ^0.8.0;

import {MonopolyLibrary} from "./libraries/MonopolyLibrary.sol";
import {GameBank} from "./Bank.sol";

contract MonopolyGame {
//    mapping(address => MonopolyLibrary.Player) public players;
////    mapping(address => MonopolyLibrary.PlayerProperties) public propertyCount;
//    GameBank public gameBank;
//
//    // Constants
//    uint8 constant BOARDWALK_POSITION = 40;
//    uint8 constant PENNSYLVANIA_POSITION = 16;
//    uint8 constant INDIANA_POSITION = 24;
//    uint8 constant GO_POSITION = 0;
//    uint8 constant MEDITERRANEAN_AVENUE = 1;
//
////mapping(uint8 => MonopolyLibrary.Chance) chance;
////mapping(uint8 => MonopolyLibrary.Chance) communityChest;
//
//    // Events
//    event PlayerMoved(address indexed player, uint8 newPosition);
//    event PlayerJailed(address indexed player);
//    event PlayerReleasedFromJail(address indexed player);
//    event BalanceUpdated(address indexed player, int256 amount);
//    event RepairsCharged(address indexed player, uint totalCost);
//
//    constructor(){
//        createChances();
//    }
//
//    // Function to advance a player to "Go"
//    function advanceToGo(address _player) public  {
//        MonopolyLibrary.Player storage player = players[_player];
//        player.playerCurrentPosition = GO_POSITION;
//        gameBank.mint(player.addr, 200);
//        emit PlayerMoved(_player, GO_POSITION);
//        emit BalanceUpdated(_player, 200);
//    }
//
//    // Move back 3 spaces
//    function moveBack3Spaces(address _player) public  {
//        MonopolyLibrary.Player storage player = players[_player];
//        player.playerCurrentPosition -= 3;
//        goTo(_player, player.playerCurrentPosition);
//    }
//
//    // Move to specific positions
//    function goToBoardwalk(address _player) public  {
//        goTo(_player, BOARDWALK_POSITION);
//    }
//
//    function goToPennsylvania(address _player) public  {
//        goTo(_player, PENNSYLVANIA_POSITION);
//    }
//
//    function goToIndianaAvenue(address _player) public  {
//        goTo(_player, INDIANA_POSITION);
//    }
//
//    // Jail-related functions
//    function goToJail(address _player) public {
//        MonopolyLibrary.Player storage player = players[_player];
//        player.inJail = true;
//        emit PlayerJailed(_player);
//    }
//
//    function getOutOfJail(address _player) public  {
//        MonopolyLibrary.Player storage player = players[_player];
//        player.inJail = false;
//        emit PlayerReleasedFromJail(_player);
//    }
//
//    // Bank-related actions
//    function collect10(address _player) public  {
//        gameBank.mint(players[_player].addr, 10);
//        emit BalanceUpdated(_player, 10);
//    }
//
//    function pay20(address _player) public  {
//        gameBank.debit(players[_player].addr, address(gameBank), 20);
//        emit BalanceUpdated(_player, -20);
//    }
//
//    function bankPays50(address _player) public  {
//        gameBank.mint(players[_player].addr, 50);
//        emit BalanceUpdated(_player, 50);
//    }
//
//    function buildingLoanMatures(address _player) public  {
//        gameBank.mint(players[_player].addr, 150);
//        emit BalanceUpdated(_player, 150);
//    }
//
//    function poorTax15(address _player) public  {
//        gameBank.debit(players[_player].addr, address(gameBank), 15);
//        emit BalanceUpdated(_player, -15);
//    }
//
//    function schoolTaxPay150(address _player) public  {
//        gameBank.debit(players[_player].addr, address(gameBank), 150);
//        emit BalanceUpdated(_player, -150);
//    }
//
//    // General repairs
//    function generalRepairs(address _player, uint costPerHouse, uint costPerHotel) public  {
////        MonopolyLibrary.PlayerProperties storage playerProps = propertyCount[_player];
////        uint totalCost = (playerProps.houses * costPerHouse) + (playerProps.hotels * costPerHotel);
////        gameBank.debit(players[_player].addr, address(gameBank), totalCost);
////        emit RepairsCharged(_player, totalCost);
//    }
//
//    // Helper function for movements
//    function goTo(address _player, uint8 newPosition) public  {
//        MonopolyLibrary.Player storage player = players[_player];
//        if (player.playerCurrentPosition > newPosition) {
//            gameBank.mint(player.addr, 200); // Passed Go
//            emit BalanceUpdated(_player, 200);
//        }
//        player.playerCurrentPosition = newPosition;
//        emit PlayerMoved(_player, newPosition);
//    }
//
//      function createChances() private {
//        chance[1] = MonopolyLibrary.Chance({
//            id: 1,
//            chance: "Advance to Go",
//            chanceType: MonopolyLibrary.ChanceType.Credit,
//            changeInPosition: 0,
//            newPosition: 0,
//            balanceChange: 0
//        });
//
//        chance[2] = MonopolyLibrary.Chance({
//            id: 2,
//            chance: "Advance to Atlantic Avenue if you pass Go collect $200",
//            chanceType: MonopolyLibrary.ChanceType.Credit,
//            changeInPosition: 0,
//            newPosition: 0,
//            balanceChange: 200
//        });
//
//        chance[3] = MonopolyLibrary.Chance({
//            id: 3,
//            chance: "Go back 3 Spaces",
//            chanceType: MonopolyLibrary.ChanceType.PositionManipulation,
//            changeInPosition: 3,
//            newPosition: 0,
//            balanceChange: 0
//        });
//
//        chance[4] = MonopolyLibrary.Chance({
//            id: 4,
//            chance: "Appointment with BoardWalk",
//            chanceType: MonopolyLibrary.ChanceType.PositionManipulation,
//            changeInPosition: 0,
//            newPosition: 40,
//            balanceChange: 0
//        });
//
//        chance[5] = MonopolyLibrary.Chance({
//            id: 5,
//            chance: "Go to Jail do not pass GO do not collect $200",
//            chanceType: MonopolyLibrary.ChanceType.PositionManipulation,
//            changeInPosition: 0,
//            newPosition: 10,
//            balanceChange: 0
//        });
//
//        chance[6] = MonopolyLibrary.Chance({
//            id: 6,
//            chance: "Christmas Funds Mature collect $10",
//            chanceType: MonopolyLibrary.ChanceType.Credit,
//            changeInPosition: 0,
//            newPosition: 0,
//            balanceChange: 10
//        });
//        chance[7] = MonopolyLibrary.Chance({
//            id: 7,
//            chance: "Amend for intoxication $20",
//            chanceType: MonopolyLibrary.ChanceType.Debit,
//            changeInPosition: 0,
//            newPosition: 0,
//            balanceChange: 20
//        });
//
//        chance[8] = MonopolyLibrary.Chance({
//            id: 8,
//            chance: "Get out of jail card be kept until neede or sold",
//            chanceType: MonopolyLibrary.ChanceType.PositionManipulation,
//            changeInPosition: 0,
//            newPosition: 10,
//            balanceChange: 0
//        });
//
//        chance[9] = MonopolyLibrary.Chance({
//            id: 9,
//            chance: "Bank pays you dividend of $50",
//            chanceType: MonopolyLibrary.ChanceType.Credit,
//            changeInPosition: 0,
//            newPosition: 0,
//            balanceChange: 50
//        });
//
//        chance[10] = MonopolyLibrary.Chance({
//            id: 10,
//            chance: "Make general repairs on all your properties for each House Pay $25, for Each hotel pay $100",
//            chanceType: MonopolyLibrary.ChanceType.Debit,
//            changeInPosition: 0,
//            newPosition: 0,
//            balanceChange: 100
//        });
//
//        chance[11] = MonopolyLibrary.Chance({
//            id: 11,
//            chance: "Pay School Tax of $150",
//            chanceType: MonopolyLibrary.ChanceType.Debit,
//            changeInPosition: 0,
//            newPosition: 0,
//            balanceChange: 150
//        });
//
//        chance[12] = MonopolyLibrary.Chance({
//            id: 12,
//            chance: "Go to Pennsylvania Railroad if you pass Go collect $200",
//            chanceType: MonopolyLibrary
//                .ChanceType
//                .CreditAndPositionManipulation,
//            changeInPosition: 0,
//            newPosition: 0,
//            balanceChange: 200
//        });
//
//        chance[13] = MonopolyLibrary.Chance({
//            id: 13,
//            chance: "Go Indiana Avenue if you pass Go collect $200",
//            chanceType: MonopolyLibrary
//                .ChanceType
//                .CreditAndPositionManipulation,
//            changeInPosition: 0,
//            newPosition: 0,
//            balanceChange: 200
//        });
//
//        chance[14] = MonopolyLibrary.Chance({
//            id: 14,
//            chance: "You are accessed for street repairs $40 per House $ 115 per hotel",
//            chanceType: MonopolyLibrary
//                .ChanceType
//                .CreditAndPositionManipulation,
//            changeInPosition: 0,
//            newPosition: 0,
//            balanceChange: 115
//        });
//        chance[15] = MonopolyLibrary.Chance({
//            id: 15,
//            chance: "Building Loan Matures collect $150",
//            chanceType: MonopolyLibrary.ChanceType.Credit,
//            changeInPosition: 0,
//            newPosition: 0,
//            balanceChange: 150
//        });
//        chance[16] = MonopolyLibrary.Chance({
//            id: 16,
//            chance: "Pay Poor tax $15",
//            chanceType: MonopolyLibrary.ChanceType.Debit,
//            changeInPosition: 0,
//            newPosition: 0,
//            balanceChange: 15
//        });
//    }
//
////     function getChance(
////        uint8 id
////    ) public view returns (MonopolyLibrary.Chance memory _chance) {
////        _chance = chance[id];
////    }
//
//        function createCommunityChest() private {
//        communityChest[1] = MonopolyLibrary.Chance({
//            id: 1,
//            chance: "Advance to Go",
//            chanceType: MonopolyLibrary.ChanceType.Credit,
//            changeInPosition: 0,
//            newPosition: 0,
//            balanceChange: 0
//        });
//
//        communityChest[2] = MonopolyLibrary.Chance({
//            id: 2,
//            chance: "Income Tax Refund collect $20",
//            chanceType: MonopolyLibrary.ChanceType.Credit,
//            changeInPosition: 0,
//            newPosition: 0,
//            balanceChange: 20
//        });
//
//        communityChest[3] = MonopolyLibrary.Chance({
//            id: 3,
//            chance: "Go back to Mediterranean Avenue",
//            chanceType: MonopolyLibrary.ChanceType.PositionManipulation,
//            changeInPosition: 0,
//            newPosition: 1,
//            balanceChange: 0
//        });
//
//        communityChest[4] = MonopolyLibrary.Chance({
//            id: 4,
//            chance: "Go to Jail do not pass GO do not collect $200",
//            chanceType: MonopolyLibrary.ChanceType.PositionManipulation,
//            changeInPosition: 0,
//            newPosition: 10,
//            balanceChange: 0
//        });
//
//        communityChest[5] = MonopolyLibrary.Chance({
//            id: 5,
//            chance: "It's your birthday every player must give you $10",
//            chanceType: MonopolyLibrary.ChanceType.Credit,
//            changeInPosition: 0,
//            newPosition: 0,
//            balanceChange: 10
//        });
//
//        communityChest[6] = MonopolyLibrary.Chance({
//            id: 6,
//            chance: "Doctors fee pay $100",
//            chanceType: MonopolyLibrary.ChanceType.Debit,
//            changeInPosition: 0,
//            newPosition: 0,
//            balanceChange: 100
//        });
//        communityChest[7] = MonopolyLibrary.Chance({
//            id: 7,
//            chance: "Pay a fine of $10 or draw a chance",
//            chanceType: MonopolyLibrary.ChanceType.Debit,
//            changeInPosition: 0,
//            newPosition: 0,
//            balanceChange: 20
//        });
//
//        communityChest[8] = MonopolyLibrary.Chance({
//            id: 8,
//            chance: "Get out of jail card be kept until needed or sold",
//            chanceType: MonopolyLibrary.ChanceType.PositionManipulation,
//            changeInPosition: 0,
//            newPosition: 10,
//            balanceChange: 0
//        });
//
//        communityChest[9] = MonopolyLibrary.Chance({
//            id: 9,
//            chance: "Receive Annual income of $100",
//            chanceType: MonopolyLibrary.ChanceType.Credit,
//            changeInPosition: 0,
//            newPosition: 0,
//            balanceChange: 100
//        });
//
//        communityChest[10] = MonopolyLibrary.Chance({
//            id: 10,
//            chance: "You have won second prize in a beauty contest collect $10",
//            chanceType: MonopolyLibrary.ChanceType.Credit,
//            changeInPosition: 0,
//            newPosition: 0,
//            balanceChange: 10
//        });
//
//        communityChest[11] = MonopolyLibrary.Chance({
//            id: 11,
//            chance: "Pay Your rising insurance Policy $50",
//            chanceType: MonopolyLibrary.ChanceType.Debit,
//            changeInPosition: 0,
//            newPosition: 0,
//            balanceChange: 50
//        });
//
//        communityChest[12] = MonopolyLibrary.Chance({
//            id: 12,
//            chance: "From sale of stock you got $50",
//            chanceType: MonopolyLibrary
//                .ChanceType
//                .Credit,
//            changeInPosition: 0,
//            newPosition: 0,
//            balanceChange: 50
//        });
//
//        communityChest[13] = MonopolyLibrary.Chance({
//            id: 13,
//            chance: "Pay Hospital $50",
//            chanceType: MonopolyLibrary
//                .ChanceType
//                .Debit,
//            changeInPosition: 0,
//            newPosition: 0,
//            balanceChange: 50
//        });
//
//        communityChest[14] = MonopolyLibrary.Chance({
//            id: 14,
//            chance: "You inherit $100",
//            chanceType: MonopolyLibrary
//                .ChanceType
//                .Credit,
//            changeInPosition: 0,
//            newPosition: 0,
//            balanceChange: 10
//        });
//        communityChest[15] = MonopolyLibrary.Chance({
//            id: 15,
//            chance: "receive your interest on loan $15",
//            chanceType: MonopolyLibrary.ChanceType.Credit,
//            changeInPosition: 0,
//            newPosition: 0,
//            balanceChange: 15
//        });
//        communityChest[16] = MonopolyLibrary.Chance({
//            id: 16,
//            chance: "Bank Error in Your Favour collect $200",
//            chanceType: MonopolyLibrary.ChanceType.Debit,
//            changeInPosition: 0,
//            newPosition: 0,
//            balanceChange: 200
//        });
//    }
//
////      function getCommunityChest(
////        uint8 id
////    ) public view returns (MonopolyLibrary.Chance memory _chance) {
////        _chance = communityChest[id];
////    }
////
//// COMMUNITY CHEST 2
//       function collect20(address _player) public  {
//        gameBank.mint(players[_player].addr, 20);
//        emit BalanceUpdated(_player, 20);
//    }
//
//    // 3
//       function goToMediterraneanAvenue(address _player) public  {
//        goTo(_player, MEDITERRANEAN_AVENUE);
//    }
//
//// 5 COLLECT $10 FOR BIRTHDAY
//    function pay20(address[] memory playerAddresses) public  {
//        for (uint8 i = 0; i < playerAddresses.length; i++) {
//            // require(
//            //     isPlayer[playerAddresses[i]],
//            //     "Address is not a registered player"
//            // );
//            // Mint tokens for each player via the GameBank
//            gameBank.mint(playerAddresses[i], 10);
//        }
//    }
//
//    function doctorsFeePay100(address _player) public  {
//        gameBank.debit(players[_player].addr, address(gameBank), 100);
//        emit BalanceUpdated(_player, -100);
//    }
//// Pay a fine of $10 or draw a chance 7
//    function payfineorChance(address _player, uint8 decision) public {
//
//        if (decision == 0){
//            gameBank.mint(_player, 10);
//        }
//    }
//    // Receive ANNUAL INCOME OF $100
//      function collectaNNUALiNCOME100(address _player) public  {
//        gameBank.mint(players[_player].addr, 100);
//        emit BalanceUpdated(_player, 100);
//    }
//
//// 2ND IN A BEAUTY CONTEST
//      function beautyContestCollect10(address _player) public  {
//        gameBank.mint(players[_player].addr, 10);
//        emit BalanceUpdated(_player, 10);
//    }
//
//    // PAY INSURANCE
//
//
//    function payInsurance50(address _player) public  {
//        gameBank.debit(players[_player].addr, address(gameBank), 50);
//        emit BalanceUpdated(_player, -50);
//    }
//
//// GAIN ON STOCK
//     function collect50(address _player) public  {
//        gameBank.mint(players[_player].addr, 50);
//        emit BalanceUpdated(_player, 50);
//    }
//
//    // PAY HOSPITAL
//
//     function payHospital50(address _player) public  {
//        gameBank.debit(players[_player].addr, address(gameBank), 50);
//        emit BalanceUpdated(_player, -50);
//    }
//
//    // YOU INHERIT $100
//       function collect100(address _player) public  {
//        gameBank.mint(players[_player].addr, 100);
//        emit BalanceUpdated(_player, 100);
//    }
//
//    // INTREST ON LOAN $15
//
//       function collectiNTERESTONlOAN15(address _player) public  {
//        gameBank.mint(players[_player].addr, 15);
//        emit BalanceUpdated(_player, 15);
//    }
//
//    // BANK ERROR
//  function BANKeRRORcollect200(address _player) public  {
//        gameBank.mint(players[_player].addr, 200);
//        emit BalanceUpdated(_player, 200);
//    }

    

}
