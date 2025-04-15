// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import {BankFactory} from "../src/BankFactory.sol";
import {Script, console} from "forge-std/Script.sol";

contract BFactory is Script {
    function run() external {
        uint256 pk = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(pk);
        BankFactory factory = BankFactory(0xe6f91F1986177a9BB54Bbcb37021422b08EeF3bE);
        address bank = factory.deployGameBank(7, 0x98D8643215747e8B81e1b90424b644C3FCFf75ea);
        //                console.log("id ", id);
        console.log("address is ", bank);

        vm.stopBroadcast();
    }
}
