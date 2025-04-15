// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import {Script, console} from "forge-std/Script.sol";
import {GameToken} from "../src/GameToken.sol";

contract GameTokenScript is Script {
    function run() external {
        uint256 privateK = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(privateK);
        GameToken token = new GameToken();
        console.log("token address :: ", address(token));
        vm.stopBroadcast();
    }
}
