// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import "../src/libraries/MonopolyLibrary.sol";
import {GameBank} from "../src/Bank.sol";
//import { MonopolyLibrary , PropertyG } from "../src/libraries/MonopolyLibrary.sol";
import {Script, console} from "forge-std/Script.sol";

contract GameBankScript is Script {
    function setUp() external {}

    function run() external {
//        GameBank gameBank = GameBank(0xB5C1efD5e6C5c8F40D528FDd4aa31C943B41f1Cb);
//        address owner = gameBank.getPropertyOwner(2);
//
//        console.log("property is ::", owner);
        uint256 pk = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(pk);
        GameBank gameBank = new GameBank(7 , 0x98D8643215747e8B81e1b90424b644C3FCFf75ea, 0x4A30f459F694876A5c6b726995274076dcD21E67);

        console.log("game bank ::: ", address (gameBank));

        vm.stopBroadcast();

    }
}
