// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {Game} from "../src/Game.sol";
import {PlayerS} from "../src/Players.sol";
import {Dice} from "../src/Dice.sol";
import {GeneralNFT} from "../src/NFT.sol";
import {EntryPoint} from "../src/account_abstraction/EntryPoint.sol";
import {Paymaster} from "../src/account_abstraction/Paymaster.sol";
import {Token} from "../src/account_abstraction/Token.sol";

contract GameTest is Test {
    Game public game;
    PlayerS public players;
    Dice private dice;
    GeneralNFT private generalNft;
    EntryPoint public entryPoint;
    Paymaster private paymaster;
    Token private token;

    uint256 private playerAKey = 1111;
    uint256 private playerBKey = 2222;
    uint256 private playerCKey = 3333;
    uint256 private playerDKey = 4444;

    address private playerA = vm.addr(playerAKey);
    address private playerB = vm.addr(playerBKey);
    address private playerC = vm.addr(playerCKey);
    address private playerD = vm.addr(playerDKey);

    function setUp() external {
        generalNft = new GeneralNFT("");
        players = new PlayerS();
        dice = new Dice();
        entryPoint = new EntryPoint();
        token = new Token(playerA);
        paymaster = new Paymaster(address(entryPoint), address(token));
    }

    function registerPlayer() private {
        players.registerPlayer(playerA, "player 1");
        players.registerPlayer(playerB, "player 2");
        players.registerPlayer(playerC, "player 3");
        players.registerPlayer(playerD, "player 4");
    }

}
