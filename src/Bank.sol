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
        bytes name;
        bytes uri;
        uint256 buyAmount;
        uint256 rentAmount;
        address owner;
        uint8 numberOfUpgrade;
    }

    // the tolerance is the extra token minted to cater for player borrowing and community card picked .
    uint256 private constant tolerace = 4;
    NFTContract private nftContract;
    uint8 private propertySize;
    mapping(uint8 => PropertyG) public gameProperties;
    uint8 private constant upgradePercentage = 7;
    uint8 private constant upgradeRentPercentage = 3;
    /**
     * @dev Initializes the contract with a fixed supply of tokens.
     * @param numberOfPlayers the total number of players.
     * @dev _mint an internal function that mints the total token needed for the game.
     */

    constructor(uint8 numberOfPlayers, address _nftContract) {
        uint256 amountToMint = numberOfPlayers + tolerace;
        require(_nftContract.code.length > 0, "not a contract address");
        nftContract = NFTContract(_nftContract);
        _mint(address(this), amountToMint);
        _gameProperties();
    }

    function _gameProperties() private {
        uint256 size = nftContract.getAllProperties().length;
        for (uint8 i = 0; i < size; i++) {
            Property memory property = nftContract.getAllProperties()[i];
            gameProperties[i + 1] =
                PropertyG(property.name, property.uri, property.buyAmount, property.rentAmount, address(this), 0);
        }
    }

    function handleRent(address player, uint8 propertyId) external {
        require(propertyId <= propertySize, "no property with the id");
        PropertyG memory foundProperty = gameProperties[propertyId];
        require(foundProperty.owner != address(0), "invalid property id provided "); //reduncdant
        require(balanceOf(player) >= foundProperty.rentAmount, "insufficient funds to pay rent");
        bool success = transferFrom(player, foundProperty.owner, foundProperty.rentAmount);
        require(success, "Transfer failed");
    }

    function transferOwnership(address newOwner, uint8 propertyId) external {
        require(propertyId <= propertySize, "no property with the id"); // to create a function or modifeir later on
        PropertyG storage foundProperty = gameProperties[propertyId];
        require(balanceOf(newOwner) >= foundProperty.buyAmount, "insufficient funds to pay rent");
        bool success = transferFrom(newOwner, foundProperty.owner, foundProperty.buyAmount);
        require(success, "Transfer failed");
        foundProperty.owner = newOwner;
        // to emit an event later on
    }

    /**
     * @dev looked this through , i think i am not getting the summation of the amount but formula is correct
     */
    function handlePropertyUpgrade(address owner, uint8 propertyId) external {
        require(propertyId <= propertySize, "no property with the id"); // to create a function or modifeir later on
        PropertyG storage foundProperty = gameProperties[propertyId];
        require(foundProperty.numberOfUpgrade <= 5, "reach peak upgrade");
        require(foundProperty.owner == owner, "you are not the owner of the property"); // not really needed but let's see 
        uint256 newUpgradeAmount = (foundProperty.buyAmount * upgradePercentage) / 100;
        require(balanceOf(owner) >= newUpgradeAmount, "insufficient funds to upgrade property");
        bool success = transferFrom(owner, address(this), newUpgradeAmount);
        require(success, "Transfer failed");
        foundProperty.numberOfUpgrade += 1;
        foundProperty.buyAmount = newUpgradeAmount;
        uint256 gottenRentAmount = foundProperty.rentAmount;
        foundProperty.rentAmount = gottenRentAmount + ((gottenRentAmount * upgradeRentPercentage) / 100);
    }
}
