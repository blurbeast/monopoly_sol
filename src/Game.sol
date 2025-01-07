//SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract Game {
    address public gameBank;

    /**
     * @dev this function initializes the game with the provided players.
     *     @dev this function calls on the bank contract and mint a certain amount of tokens for each player.
     *     @param players the addresses of the players.
     *
     *     @dev this function should emit an event
     */
    function startGame(address[] memory players) external {}
}
