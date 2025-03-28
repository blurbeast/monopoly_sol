// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;
import { BankFactory } from "../src/BankFactory.sol";
import { Script, console } from "forge-std/Script.sol";
contract BankFactoryScript is Script {
    function setUp() public {}
    function run() external {
        uint256 privateK = vm.envUint("PRIVATE_KEY");

        // connect to the network via broadcast
        vm.startBroadcast(privateK);

        // call on the bank factory contract using the new keyword
        //tells it to create an instance or object of the bank factory contract
        BankFactory factory = new BankFactory(address (0));

        console.log("address of the factory contract", address (factory));

        vm.stopBroadcast();

    }
}