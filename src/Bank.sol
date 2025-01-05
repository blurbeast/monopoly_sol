//SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {ERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
// import { ERC20 } from "lib/solmate/src/tokens/ERC20.sol";

/**
 * @title GameBank
 * @dev A simple ERC20 token representing a game bank.
 * @dev this is intended to be deployed upon every new creation of a new game.
 */
contract GameBank is ERC20("GameBank", "GB") {
    struct Property {
        string name;
        string description;
        uint256 buyAmount;
        uint256 rentAmount;
        address owner;
    }

    // the tolerance is the extra token minted to cater for player borrowing and community card picked .
    uint256 private constant tolerace = 4;
    address private nftContract;

    /**
     * @dev Initializes the contract with a fixed supply of tokens.
     * @param numberOfPlayers the total number of players.
     * @dev _mint an internal function that mints the total token needed for the game.
     */
    constructor(uint8 numberOfPlayers) {
        uint256 amountToMint = numberOfPlayers + tolerace;
        _mint(address(this), amountToMint);
    }
}
