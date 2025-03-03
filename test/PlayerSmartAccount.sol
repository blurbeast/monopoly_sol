

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/account_abstraction/EntryPoint.sol";
import "../src/account_abstraction/interfaces/ISmartAccount.sol";
import "../src/Players.sol";



contract PlayerSmartAccountTest is Test {

    EntryPoint public entryPoint;
    PlayerS public players;
    address private playerA = address(0xa);
    
    function setUp() external {
        entryPoint = new EntryPoint();
        players = new PlayerS();
    }

    function testRegisterPlayer() external {
        players.setEntryPoint(address(entryPoint));
        players.registerPlayer(playerA, "playerA");

        address playerSmartAccountAddress = players.playerSmartAccount(playerA);

        assertGt(playerSmartAccountAddress.code.length , 0);

        // gotten smart account owner should be playerA
        address gottenSmartAccountOwner = ISmartAccount(playerSmartAccountAddress).owner();
        assertEq(gottenSmartAccountOwner, playerA);
    }

}