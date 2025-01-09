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
        uint noOfTimesSold;
        bool isMortgaged;
        uint mortgageAmount;
    }

    mapping(uint => Property) public properties;

    event PropertySold(uint propertyId, address owner, uint price);
    event RentPaid(
        address tenant,
        address landlord,
        uint rentPrice,
        string property
    );
    event PropertyMortgaged(
        uint propertyId,
        uint mortgageAmount,
        address owner
    );

    event PropertyListedForSale(
        uint propertyId,
        uint propertyPrice,
        address owner
    );

    // the tolerance is the extra token minted to cater for player borrowing and community card picked .
    uint256 private constant tolerace = 4;
    address private nftContract;

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
    }

    /**
        @dev player should be able to buy a property.
        @dev this function emits an event when a player buys a property.

        @param propertyId The id of the property.
        @dev player should only be able to buy a property if they have enough money.
        @dev player should only be able to buy a property when they land on the property
        @dev player should only be able to buy a property if they are not bankrupt.
        @dev player should only be able to buy a property if it should owned by the bank
     */

    function buyProperty(uint256 propertyId) external {
        Property storage property = properties[propertyId];

        require(property.owner != msg.sender, "You already own the property");
        require(
            property.buyAmount > 0,
            "Property price must be greater than zero"
        );

        // Transfer funds
        address recipient = (property.noOfTimesSold > 0)
            ? property.owner
            : address(this);
        bool success = transfer(recipient, property.buyAmount);
        require(success, "Token transfer failed");

        // Update ownership and increment sales count
        property.owner = msg.sender;
        property.noOfTimesSold++;

        // Emit an event for the purchase
        emit PropertySold(propertyId, msg.sender, property.buyAmount);
    }

    /**
     @dev player should be able to sell a property.
     @dev this function emits an event when a player sells a property.

     @param propertyId The id of the property.
     @dev player should only be able to sell a property if they own the property.
     */
    function sellProperty(uint256 propertyId) external {
        Property storage property = properties[propertyId];

        require(
            property.owner == msg.sender,
            "You are not the owner of this property"
        );
        require(
            !property.isMortgaged,
            "Property is mortgaged and cannot be sold"
        );

        emit PropertyListedForSale(propertyId, property.buyAmount, msg.sender);
    }

    /**
     @dev player should be able to rent a property.
     @dev this function emits an event when a player rent a property.

     @param propertyId The id of the property.

     @dev property owner should recieve the money for the rent.
     @dev rent is 20% of the actual price of the property.
     */
    function rentProperty(uint256 propertyId) external {
        Property storage property = properties[propertyId];
        require(property.owner != address(0), "Invalid current owner");
        require(property.owner != msg.sender, "You can't rent your property");

        bool success = transfer(property.owner, property.rentAmount);
        require(success, "Token transfer failed");

        emit RentPaid(
            msg.sender,
            property.owner,
            property.rentAmount,
            property.name
        );
    }

    /**
        @dev player should be able to upgrade a property.
        @dev this function emits an event when a player upgrades a property.

        @param propertyId The id of the property.
        @dev player should only be able to upgrade a property if they own the property.
        @dev player should only be able to upgrade a property if they have enough money to do so.
        @dev upgrade cost should be 30% of the present price of the property.
        @dev upgrade level of a property should be incremented by 1.
        @dev upgrade level of a property should be limited to 5.

     */

    // Function to mortgage a property
    function mortgageProperty(uint256 propertyId) external {
        Property storage property = properties[propertyId];

        require(
            property.owner == msg.sender,
            "You are not the owner of this property"
        );
        require(!property.isMortgaged, "Property is already mortgaged");

        property.isMortgaged = true;
        uint mortgageAmount = property.buyAmount / 2;
        // Transfer funds to the owner
        bool success = transferFrom(
            address(this),
            msg.sender,
            property.mortgageAmount
        );
        require(success, "Token transfer failed");

        emit PropertyMortgaged(propertyId, mortgageAmount, msg.sender);
    }

    // Function to release a mortgage
    function releaseMortgage(uint256 propertyId) external {
        Property storage property = properties[propertyId];

        require(
            property.owner == msg.sender,
            "You are not the owner of this property"
        );
        require(property.isMortgaged, "Property is not mortgaged");

        // Transfer the repaid funds to the contract owner or use it for future logic
        bool success = transfer(address(this), property.buyAmount);
        require(success, "Token transfer failed");

        // Release the mortgage
        property.isMortgaged = false;
    }

    function upgradeProperty(uint256 propertyId) external {}
}
