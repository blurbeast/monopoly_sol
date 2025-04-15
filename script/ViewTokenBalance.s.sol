// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {GameToken} from "../src/GameToken.sol";

contract ViewBalance is Script {
    function run() external {
        //        address contractAddress = address (0x9Bb0c295d374e45afc73ECEe231a8db0eA44be8F);
        address contractAddress = address(0x272D75aC429D2C46a9fa71CEb9436F7d71E286e8); // with all prop function
        address player1SmartAccount = address(0xCE3bf0d25E319cC5DBb57729677E5D578C7ba47a);
        address player2SmartAccount = address(0x5922E9FaF5Bba23dCb5E0d22a231239A99132034);

        GameToken token = GameToken(address(0x4A30f459F694876A5c6b726995274076dcD21E67));
        uint256 balance = token.balanceOf(contractAddress, contractAddress);

        console.log("user balance is ::: ", balance);
    }
}
