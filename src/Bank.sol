//SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {ERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
// import { ERC20 } from "lib/solmate/src/tokens/ERC20.sol";

struct Property {
        bytes name;
        uint256 rentAmount;
        bytes uri;
        uint256 buyAmount;
        PropertyType propertyType;
        PropertyColors color;
    }

   enum PropertyColors {
        PINK,
        YELLOW,
        BLUE,
        ORANGE,
        RED,
        GREEN,
        PURPLE,
        BROWN
    }

enum PropertyType {
    Property,
    RailStation,
    Utility,
    Special
}

event RentPaid(address tenant, address landlord, uint256 rentPrice, bytes property);

event PropertyMortgaged(uint256 propertyId, uint256 mortgageAmount, address owner);

event PropertyListedForSale(uint256 propertyId, uint256 propertyPrice, address owner);

event PropertyUpGraded(uint256 propertyId);

event PropertyDownGraded(uint256 propertyId);

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
        uint8 noOfUpgrades;
        PropertyType propertyType;
        PropertyColors propertyColor;
    }

    struct Bid {
        address bidder;
        uint256 bidAmount;
    }

    mapping(uint8 => Bid) public bids;
    mapping(uint8 => address) propertyOwner;
    mapping(uint256 => bool) mortgagedProperties;
    mapping(uint8 => uint8) noOfUpgrades;
    mapping(PropertyColors => mapping(address => uint8)) public noOfColorGroupOwned;

    event PropertyBid(uint8 indexed propertyId, address indexed bidder, uint256 bidAmount);
    event PropertySold(uint8 indexed propertyId, address indexed newOwner, uint256 amount);

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
        Property[] memory allProperties = nftContract.getAllProperties();
        uint256 size = allProperties.length;

        for (uint8 i = 0; i < size; i++) {
            Property memory property = allProperties[i];
            distributePropertyType(property, i);
        }
    }

    function distributePropertyType(Property memory prop, uint8 position) private {
        gameProperties[position + 1] =
            PropertyG(prop.name, prop.uri, prop.buyAmount, prop.rentAmount, address(this), 0, prop.propertyType, prop.color);
    }

    function buyProperty(uint8 propertyId, uint256 bidAmount) external {
        PropertyG storage property = gameProperties[propertyId];
        require(property.propertyType != PropertyType.Special, "Invalid property");
        require(property.owner != msg.sender, "You already own the property");
        require(property.buyAmount > 0, "Property price must be greater than zero");
        require(bidAmount >= property.buyAmount, "Bid amount must be at least the property price");
        require(!mortgagedProperties[propertyId], "Property is Mortgaged and cannot be bought");

        // Approve contract to spend bid amount (requires user to call `approve` beforehand)
        require(balanceOf(msg.sender) >= bidAmount, "Insufficient funds for bid");

        if (property.owner == address(this)) {
            // bool success = transfer(address(this), property.buyAmount);
            bool success = transferFrom(msg.sender, address(this), property.buyAmount);
            require(success, "Token transfer failed");

            // Update ownership and increment sales count
            property.owner = msg.sender;
            propertyOwner[propertyId] = msg.sender;
        } else {
            // Call the ERC20 approve function
            bool success = approve(property.owner, bidAmount);
            require(success, "Token approval failed");

            // Store the bid information
            bids[propertyId] = Bid({bidder: msg.sender, bidAmount: bidAmount});
        }

        // Emit a bid event
        emit PropertyBid(propertyId, msg.sender, bidAmount);
    }

    function sellProperty(uint8 propertyId) external {
        PropertyG storage property = gameProperties[propertyId];
        require(!mortgagedProperties[propertyId], "Property is Mortgaged and cannot be sold");
        Bid memory bid = bids[propertyId];

        require(property.propertyType != PropertyType.Special, "Invalid property");
        require(property.owner == msg.sender, "You do not own this property");
        require(bid.bidder != address(0), "No valid bid found for this property");

        // Transfer funds from bidder to seller
        bool success = transferFrom(bid.bidder, msg.sender, bid.bidAmount);
        require(success, "Token transfer failed");

        // Update ownership
        property.owner = bid.bidder;
        propertyOwner[propertyId] = bid.bidder;

        // Clear the bid
        delete bids[propertyId];

        // Emit a property sold event
        emit PropertySold(propertyId, bid.bidder, bid.bidAmount);
    }

    function _checkRailStationRent(uint8 propertyId) private view returns (uint256) {
        uint256 rent = 0;
        address railOwner = propertyOwner[propertyId];
        // Count how many railway stations are owned by the player
        uint256 ownedRailways = 0;

        if (propertyOwner[6] == railOwner) ownedRailways++;
        if (propertyOwner[16] == railOwner) ownedRailways++;
        if (propertyOwner[26] == railOwner) ownedRailways++;
        if (propertyOwner[36] == railOwner) ownedRailways++;

        // Set rent based on the number of owned railway stations
        if (ownedRailways == 4) {
            rent = 200; // Rent for owning all 4
        } else if (ownedRailways == 3) {
            rent = 100; // Rent for owning 3
        } else if (ownedRailways == 2) {
            rent = 50; // Rent for owning 2
        } else if (ownedRailways == 1) {
            rent = 25; // Rent for owning 1
        }

        return rent;
    }

    function _checkUtilityRent(uint8 propertyId, uint256 diceRolled) private view returns (uint256) {
        uint256 rentAmount = 0;

        // Check if the property is either 13 or 29 (the utility properties)
        if (propertyId == 13 || propertyId == 29) {
            // Check if both utility properties are owned by the same player
            if (propertyOwner[13] == propertyOwner[29]) {
                rentAmount = diceRolled * 10; // Rent when both utilities are owned by the same player
            } else {
                rentAmount = diceRolled * 4; // Rent when utilities are owned by different players
            }
        }

        return rentAmount;
    }

    function handleRent(address player, uint8 propertyId, uint256 diceRolled) external {
        require(propertyId <= propertySize, "No property with the given ID");
        require(!mortgagedProperties[propertyId], "Property is Mortgaged no rent");
        PropertyG storage foundProperty = gameProperties[propertyId];
        require(foundProperty.owner != address(this), "Property does not have an owner");

        uint256 rentAmount;

        // Check if the property is a Utility
        if (foundProperty.propertyType == PropertyType.Utility) {
            rentAmount = _checkUtilityRent(propertyId, diceRolled);
        }
        // Check if the property is a Rail Station
        else if (foundProperty.propertyType == PropertyType.RailStation) {
            rentAmount = _checkRailStationRent(propertyId);
        }
        // Regular Property Rent
        else {
            rentAmount = foundProperty.rentAmount;
        }

        // Ensure player has enough funds to pay rent
        require(balanceOf(player) >= rentAmount, "Insufficient funds to pay rent");

        // Transfer the rent to the owner
        bool success = transferFrom(player, foundProperty.owner, rentAmount);
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

    // Function to mortgage a property
    function mortgageProperty(uint8 propertyId) external {
        PropertyG storage property = gameProperties[propertyId];
        require(!mortgagedProperties[propertyId], "Property is already Mortgaged");

        require(property.owner == msg.sender, "You are not the owner of this property");
        mortgagedProperties[propertyId] = true;

        uint256 mortgageAmount = property.buyAmount / 2;
        // Transfer funds to the owner
        bool success = transferFrom(address(this), msg.sender, mortgageAmount);
        require(success, "Token transfer failed");

        emit PropertyMortgaged(propertyId, mortgageAmount, msg.sender);
    }

    // Function to release a mortgage
    function releaseMortgage(uint8 propertyId) external {
        PropertyG storage property = gameProperties[propertyId];

        require(property.owner == msg.sender, "You are not the owner of this property");
        require(mortgagedProperties[propertyId], "Property is not Mortgaged");

        // Transfer the repaid funds to the contract owner or use it for future logic
        bool success = transfer(address(this), property.buyAmount);
        require(success, "Token transfer failed");

        // Release the mortgage
        mortgagedProperties[propertyId] = false;
    }

    /**
     * @dev It's important to note that only properties can be upgraded and down graded railstations and companies cannot
     *  a 2d mapping of string to address to number
     *  we can upgrade the three at once
     */
    function upgradeProperty(uint8 propertyId) external {
        PropertyG storage property = gameProperties[propertyId];

        require(property.owner == msg.sender, "You are not the owner of this property");
        require(!mortgagedProperties[propertyId], "Property is Mortgaged cannot upgrade");
        require(property.propertyType == PropertyType.Property, "Only properties can be upgraded");
        // require(noOfUpgrades[propertyId] <= 5, "Property at Max upgrade");

        // Calculate the cost of one house
        uint256 costOfHouse = property.buyAmount;



        // Check if the property is ready to upgrade to a hotel
        if (property.noOfUpgrades == 4) {
            // Ensure the player has enough tokens to upgrade to a hotel
            require(transfer(address(this), costOfHouse), "Token transfer for hotel failed");

            // Upgrade to hotel
            // property.hotel = true;
            property.noOfUpgrades = 0; // Reset house count after upgrading
        } else {
            // Ensure the player has enough tokens to buy a house
            require(transfer(address(this), costOfHouse), "Token transfer for house failed");

            // Increment the house count
            property.noOfUpgrades++;
        }
        emit PropertyUpGraded(propertyId);
    }

    function downgradeProperty(uint8 propertyId) external {
        PropertyG memory property = gameProperties[propertyId];

        // Ensure the caller is the owner of the property
        require(property.owner == msg.sender, "You are not the owner of this property");

        // Ensure the property is not mortgaged
        // require(!property.isMortgaged, "Cannot downgrade a mortgaged property");

        // Check if the property has a hotel to downgrade
        if (property.noOfUpgrades == 5) {
            // Downgrade hotel to 4 houses
            // property.hotel = false;
            property.noOfUpgrades = 4;

            // Refund the equivalent of one house to the owner
            uint256 refundAmount = property.buyAmount / 2;
            require(transfer(msg.sender, refundAmount), "Token refund for hotel downgrade failed");
        } else if (property.noOfUpgrades > 0) {
            // Downgrade one house
            property.noOfUpgrades--;

            // Refund the cost of one house
            uint256 refundAmount = property.buyAmount / 2;
            require(transfer(msg.sender, refundAmount), "Token refund for house downgrade failed");
        } else {
            // Property has no upgrades to downgrade
            revert("Property has no houses or hotel to downgrade");
        }
        emit PropertyDownGraded(propertyId);
    }
}
