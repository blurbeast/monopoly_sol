//SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {PlayerS} from "../src/Players.sol";
import {Test, console} from "forge-std/Test.sol";

contract PlayersTest is Test {
    PlayerS public playerS;

    address private playerA = address(0xa);
    address private playerB = address(0xb);

    function setUp() external {
        playerS = new PlayerS();
    }

    function testRegisterPlayer() external {
        playerS.registerPlayer(playerA, "playerA");

        bool result = playerS.alreadyRegistered(playerA);

        assertEq(result, true);
    }

    function testNoDuplicateAddressAndUsernameAllowed() external {
        playerS.registerPlayer(playerA, "alice");

        vm.expectRevert("player already registered");
        playerS.registerPlayer(playerA, "playerB");

        vm.expectRevert("username is already taken");
        playerS.registerPlayer(playerB, "alice");

        bool result = playerS.alreadyRegistered(playerA);

        bytes memory username = bytes("alice");

        assertEq(playerS.usernameExists(username), true);

        bytes memory gottenPlayerUsername = playerS.playerUsernames(playerA);

        assertEq(result, true);
        assertEq(gottenPlayerUsername, username);
    }
}
