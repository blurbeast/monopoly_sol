// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {Counter} from "../src/Counter.sol";
import {GameToken} from "../src/GameToken.sol";


contract ViewBalance is Script {

    function run() external {

        address contractAddress = address (0x3c992aC9922E08ACE021a793B068dE1Ca5e28896);
        address player1SmartAccount = address (0x6235dCe6c3B06F54992F49E668b6227bf1814922);
        address player2SmartAccount = address (0x612eD1c61b9278a7E5f3BC27168e47C8E39e04A7);

        GameToken token = GameToken(address (0x4A30f459F694876A5c6b726995274076dcD21E67));
        uint256 balance = token.balanceOf(player2SmartAccount, contractAddress);

        console.log("user balance is ::: ", balance);
    }
}