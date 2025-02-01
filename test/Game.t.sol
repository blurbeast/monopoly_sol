//SPDX-License-Identifier: MIT
pragma solidity ^ 0.8.26;


import {Test} from "forge-std/Test.sol";
import {Game} from "../src/Game.sol";

contract GameTest is Test {

    Game private game;

    function setUp() external {
        game = new Game();
    }
}