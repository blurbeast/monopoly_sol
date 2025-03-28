// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import {Script, console} from "forge-std/Script.sol";
import { GameToken } from "../src/GameToken.sol";


contract GameTokenScript is Script {
    function run() external {
        uint256 privateK = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(privateK);
        GameToken token = new GameToken();
        console.log("token address :: ", address (token));
        vm.stopBroadcast();
    }
} // 0x4A30f459F694876A5c6b726995274076dcD21E67