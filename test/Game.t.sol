//SPDX-License-Identifier: MIT
pragma solidity ^ 0.8.26;

import {Test} from "forge-std/Test.sol";
import {Game} from "../src/Game.sol";
import {GeneralNFT} from "../src/NFT.sol";
import {PlayerS} from "../src/Players.sol";
import {Dice} from "../src/Dice.sol";

contract GameTest is Test {
    Game private game;
    GeneralNFT private generalNft;
    PlayerS private players;
    Dice private dice;

    function setUp() external {
        generalNft = new GeneralNFT("");
        players = new PlayerS();
        dice = new Dice();
        
        // game = new Game();
    }
}
