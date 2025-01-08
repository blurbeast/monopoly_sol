//SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {ERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
// import { ERC20 } from "lib/solmate/src/tokens/ERC20.sol";

  struct Property {
        bytes name;
        uint256 rentAmount;
        bytes uri;
        uint256 buyAmount;
    }


interface NFTContract {
    function getAllProperties() external view returns (Property[] memory);
}
/**
 * @title GameBank
 * @dev A simple ERC20 token representing a game bank.
 * @dev this is intended to be deployed upon every new creation of a new game.
 */

contract GameBank is ERC20("GameBank", "GB") {
    struct PropertyG {
        string name;
        string uri;
        uint256 buyAmount;
        uint256 rentAmount;
        address owner;
    }

    // the tolerance is the extra token minted to cater for player borrowing and community card picked .
    uint256 private constant tolerace = 4;
    NFTContract private nftContract;
    PropertyG[] gamePropertiesG;

    /**
     * @dev Initializes the contract with a fixed supply of tokens.
     * @param numberOfPlayers the total number of players.
     * @dev _mint an internal function that mints the total token needed for the game.
     */
    constructor(uint8 numberOfPlayers, address _nftContract) {
        uint256 amountToMint = numberOfPlayers + tolerace;
        nftContract = NFTContract(_nftContract);
        _mint(address(this), amountToMint);
    }

    function gameProperties() private {
        uint256 size = nftContract.getAllProperties().length;
        for(uint8 i = 1; i <= size; i++) {
            Property memory property = nftContract.getAllProperties()[i];
            gamePropertiesG[i] = PropertyG (
                string(property.name),
                string(property.uri),
                property.buyAmount,
                property.rentAmount,
                address(this)
            );
        }
    }
}
