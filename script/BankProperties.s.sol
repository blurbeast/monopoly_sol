// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {GameToken} from "../src/GameToken.sol";
import {GameBank} from "../src/Bank.sol";

contract BankProperties {
    function run() external {
        GameBank gameBank = GameBank(0x272D75aC429D2C46a9fa71CEb9436F7d71E286e8);
        gameBank.getProperties();
    }
}
