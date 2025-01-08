//SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {GameBank} from "./Bank.sol";

contract Game {
    GameBank gameBank;
    uint8 numberOfPlayers;

    constructor(address _nftContract, address[] memory players) {
        require(players.length > 0 && players.length < 10, "exceed the allowed number of players");
        for (uint8 i = 0; i < players.length; i++) {
            require(players[i].code.length == 0, "player address must be an EOA");
        }
        gameBank = new GameBank(uint8(players.length), _nftContract);
        numberOfPlayers = uint8(players.length);
    }

    /**
     * @dev this function initializes the game with the provided players.
     *     @dev this function calls on the bank contract and mint a certain amount of tokens for each player.
     *     @param players the addresses of the players.
     *
     *     @dev this function should emit an event
     */
    function startGame(address[] memory players) external {}
}
