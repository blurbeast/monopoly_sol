// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import { GameBank } from "../src/Bank.sol";
import {GeneralNFT} from "../src/NFT.sol";



// this is the test contract to test all of the functionalities of the bank contract in the source file

contract BankTest is Test {
    GameBank gameBank;
    GeneralNFT generalNft;

    function setUp() public {
        generalNft = new GeneralNFT("");
        gameBank = new GameBank(4, address(generalNft));
    }
}