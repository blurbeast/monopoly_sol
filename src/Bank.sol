//SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {ERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import "./libraries/MonopolyLibrary.sol";
// import { ERC20 } from "lib/solmate/src/tokens/ERC20.sol";
// import "lib/openzeppelin-contracts/contracts/access/Ownable.sol";



event RentPaid(address tenant, address landlord, uint256 rentPrice, bytes property);

event PropertyMortgaged(uint256 propertyId, uint256 mortgageAmount, address owner);

event PropertyListedForSale(uint256 propertyId, uint256 propertyPrice, address owner);

event PropertyUpGraded(uint256 propertyId);

event PropertyDownGraded(uint256 propertyId);

interface NFTContract {
    function getAllProperties() external view returns (MonopolyLibrary.Property[] memory);
}

/**
 * @title GameBank
 * @dev A simple ERC20 token representing a game bank.
 * @dev this is intended to be deployed upon every new creation of a new game.
 */
contract GameBank is ERC20("GameBank", "GB") {
    using MonopolyLibrary for MonopolyLibrary.PropertyG;
    using MonopolyLibrary for MonopolyLibrary.Property;
    using MonopolyLibrary for MonopolyLibrary.PropertyColors;
    using MonopolyLibrary for MonopolyLibrary.PropertyType;

    // MonopolyLibrary.PropertyG public PropertyG;
    // MonopolyLibrary.Property public Property;

    struct Bid {
        address bidder;
        uint256 bidAmount;
    }

    enum BenefitType {
        FREE_RENT,
        RENT_DISCOUNT,
        PROPERTY_ROYALTY
    }

    struct Benefit {
        BenefitType benefitType;
        bool isActive;
        uint8 benefitValue;
        uint8 numberOfTurns;
    }

    struct Proposal {
        address user;
        // address biddedUser;
        uint8 proposedPropertyId;
        uint8 biddedPropertyId;
        uint256 biddedTokenAmount;
        mapping(uint8 => Benefit) benefits;
        uint8 numberOfBenefits;
    }

    MonopolyLibrary.PropertyG[] properties;

    mapping(uint8 => Bid) public bids;
    mapping(uint8 => address) propertyOwner;
    mapping(uint256 => bool) mortgagedProperties;
    mapping(uint8 => uint8) noOfUpgrades;
    //
    mapping(MonopolyLibrary.PropertyColors => mapping(address => uint8)) public noOfColorGroupOwnedByUser;
    mapping(MonopolyLibrary.PropertyColors => uint8) private upgradeUserPropertyColorOwnedNumber;

    event PropertyBid(uint8 indexed propertyId, address indexed bidder, uint256 bidAmount);
    event PropertySold(uint8 indexed propertyId, address indexed newOwner, uint256 amount);

    // the tolerance is the extra token minted to cater for player borrowing and community card picked .
    uint256 private constant tolerace = 4;
    NFTContract private nftContract;
    uint8 private propertySize;
    mapping(uint8 => MonopolyLibrary.PropertyG) public gameProperties;
    // uint8 private constant upgradePercentage = 7;
    // uint8 private constant upgradeRentPercentage = 3;

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
        _setNumberForColoredPropertyNumber();
    }

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }

    //helper function
    function _gameProperties() private {
        MonopolyLibrary.Property[] memory allProperties = nftContract.getAllProperties();
        uint256 size = allProperties.length;
        for (uint8 i = 0; i < size; i++) {
            MonopolyLibrary.Property memory property = allProperties[i];
            _distributePropertyType(property, i);
        }
    }
    //helper function

    function _setNumberForColoredPropertyNumber() private {
        upgradeUserPropertyColorOwnedNumber[MonopolyLibrary.PropertyColors.PINK] = 3;
        upgradeUserPropertyColorOwnedNumber[MonopolyLibrary.PropertyColors.YELLOW] = 3;
        upgradeUserPropertyColorOwnedNumber[MonopolyLibrary.PropertyColors.BLUE] = 3;
        upgradeUserPropertyColorOwnedNumber[MonopolyLibrary.PropertyColors.ORANGE] = 3;
        upgradeUserPropertyColorOwnedNumber[MonopolyLibrary.PropertyColors.RED] = 3;
        upgradeUserPropertyColorOwnedNumber[MonopolyLibrary.PropertyColors.GREEN] = 3;
        upgradeUserPropertyColorOwnedNumber[MonopolyLibrary.PropertyColors.PURPLE] = 3;
        upgradeUserPropertyColorOwnedNumber[MonopolyLibrary.PropertyColors.BROWN] = 2;
    }

    //helper function
    function _distributePropertyType(MonopolyLibrary.Property memory prop, uint8 position) private {
        gameProperties[position + 1] = MonopolyLibrary.PropertyG(
            prop.name, prop.uri, prop.buyAmount, prop.rentAmount, address(this), 0, prop.propertyType, prop.color
        );
    }

    // correct
    function buyProperty(uint8 propertyId, uint256 bidAmount, address buyer) external {
        MonopolyLibrary.PropertyG storage property = gameProperties[propertyId];
        require(property.propertyType != MonopolyLibrary.PropertyType.Special, "Invalid property");
        require(property.owner != msg.sender, "You already own the property");
        // require(property.buyAmount > 0, "Property price must be greater than zero");
        require(bidAmount >= property.buyAmount, "Bid amount must be at least the property price");
        require(!mortgagedProperties[propertyId], "Property is Mortgaged and cannot be bought");
        require(property.owner == address(this), "already owned by a player");

        // // Approve contract to spend bid amount (requires user to call `approve` beforehand)
        // require(balanceOf(msg.sender) >= bidAmount, "Insufficient funds for bid");

         _transfer(buyer, address(this), property.buyAmount);  
        
  // Update ownership and increment sales count
        property.owner = msg.sender;
        propertyOwner[propertyId] = msg.sender;

        noOfColorGroupOwnedByUser[property.propertyColor][msg.sender] += 1;

        property.propertyType == MonopolyLibrary.PropertyType.RailStation ? numberOfOwnedRailways[msg.sender] += 1 : 0;

        // // Emit an event
    }

    mapping(uint256 => Proposal) public inGameProposals;
    mapping(uint8 => uint8) public propertyToProposal;
    uint256 private proposalIds;

    // correct i think
    function makeProposal(
        address _user,
        // address _biddedUser,
        uint8 proposedPropertyId,
        uint8 biddedPropertyId,
        uint8[] calldata benefitValue,
        BenefitType[] calldata benefitType,
        uint8[] calldata numberOfTurns,
        uint256 biddedTokenAmount
    ) external {
        require(benefitType.length == benefitValue.length && benefitValue.length == numberOfTurns.length, "");
        address realOwner = propertyOwner[proposedPropertyId];
        require(realOwner == _user, "only property owner can perform this action");
        require(!mortgagedProperties[proposedPropertyId], "proposed property has been mortgaged ");

        uint8 benefitSize = uint8(benefitValue.length);

        require(benefitSize < 3, "the benefit offer should not be more than 3");

        // mapping (uint8 => Benefit) proposalBenefits;

        proposalIds += 1;
        Proposal storage proposal = inGameProposals[proposalIds];
        proposal.user = _user;
        proposal.proposedPropertyId = proposedPropertyId;
        proposal.biddedPropertyId = biddedPropertyId;
        proposal.biddedTokenAmount = biddedTokenAmount;
        proposal.numberOfBenefits = benefitSize;

        for (uint8 i = 0; i < benefitSize; i++) {
            proposal.benefits[i + 1] = Benefit({
                benefitType: benefitType[i],
                isActive: false,
                benefitValue: benefitValue[i],
                numberOfTurns: numberOfTurns[i]
            });
        }

        // to emit an event here
    }

    // in progress
    function acceptProposal(address _user, uint8 proposalId) external {
        Proposal storage proposal = inGameProposals[proposalId];

        address realOwner = propertyOwner[proposal.biddedPropertyId];

        require(realOwner == _user, "only owner can perform action");
        require(!mortgagedProperties[proposal.biddedPropertyId], "property is on mortgage");

        if (proposal.biddedTokenAmount > 0) {
            require(balanceOf(proposal.user) >= proposal.biddedTokenAmount, "");

            _transfer(proposal.user, _user, proposal.biddedTokenAmount);
        }

        uint8 sizeOfBenefits = uint8(proposal.numberOfBenefits);

        for (uint8 i = 0; i < sizeOfBenefits; i++) {
            proposal.benefits[i].isActive = true;
        }

        // make changes to the property
        // i think refactoring the property struct will be okay here as we should only read from the state here
        // here the owner is vague as it would cost more here
        // the mapping propertyOwner handles this
        // moving on it should be changed

        MonopolyLibrary.PropertyG storage property = gameProperties[proposal.biddedPropertyId];
        property.owner = proposal.user;

        propertyOwner[proposal.biddedPropertyId] = proposal.user;
        propertyOwner[proposal.proposedPropertyId] = realOwner;

        MonopolyLibrary.PropertyG storage proposedProperty = gameProperties[proposal.proposedPropertyId];
        proposedProperty.owner = realOwner;

        // change the color number for each property
        noOfColorGroupOwnedByUser[property.propertyColor][realOwner] -= 1;
        noOfColorGroupOwnedByUser[property.propertyColor][proposal.user] += 1;

        noOfColorGroupOwnedByUser[proposedProperty.propertyColor][realOwner] += 1;
        noOfColorGroupOwnedByUser[proposedProperty.propertyColor][proposal.user] -= 1;

        //confirm if it is a rail station
        property.propertyType == MonopolyLibrary.PropertyType.RailStation
            ? numberOfOwnedRailways[proposal.user] += 1
            : numberOfOwnedRailways[realOwner] -= 1;

        property.propertyType == MonopolyLibrary.PropertyType.RailStation
            ? numberOfOwnedRailways[realOwner] += 1
            : numberOfOwnedRailways[proposal.user] -= 1;

        propertyToProposal[proposal.proposedPropertyId] = proposalId;
        // to emit an event here
    }

    // to refactor this function
    // to be private later on .
    function _sellProperty(uint8 propertyId) external {
        MonopolyLibrary.PropertyG storage property = gameProperties[propertyId];
        require(!mortgagedProperties[propertyId], "Property is Mortgaged and cannot be sold");

        Bid memory bid = bids[propertyId];

        require(property.propertyType != MonopolyLibrary.PropertyType.Special, "Invalid property");
        require(property.owner == msg.sender, "You do not own this property");
        require(bid.bidder != address(0), "No valid bid found for this property");

        // Transfer funds from bidder to seller
        bool success = transferFrom(bid.bidder, msg.sender, bid.bidAmount);
        require(success, "Token transfer failed");

        // Update ownership
        property.owner = bid.bidder;
        propertyOwner[propertyId] = bid.bidder;

        noOfColorGroupOwnedByUser[property.propertyColor][msg.sender] -= 1;
        noOfColorGroupOwnedByUser[property.propertyColor][bid.bidder] += 1;

        // Clear the bid
        delete bids[propertyId];

        // Emit a property sold event
        emit PropertySold(propertyId, bid.bidder, bid.bidAmount);
    }

    mapping(address => uint8) private numberOfOwnedRailways;

    function _checkRailStationRent(uint8 propertyId) private view returns (uint256) {
        address railOwner = propertyOwner[propertyId];
        // Count how many railway stations are owned by the player
        uint256 ownedRailways = numberOfOwnedRailways[railOwner];

        return 25 * (2 ** (ownedRailways - 1));
    }

    function _checkUtilityRent(uint8 propertyId, uint256 diceRolled) private view returns (uint256) {
        require(propertyId == 13 || propertyId == 29, "");

        return propertyOwner[13] == propertyOwner[29] ? (diceRolled * 10) : (diceRolled * 4);
    }

    function handleRent(address player, uint8 propertyId, uint256 diceRolled) external {
        require(propertyId <= propertySize, "No property with the given ID");
        require(!mortgagedProperties[propertyId], "Property is Mortgaged no rent");
        MonopolyLibrary.PropertyG storage foundProperty = gameProperties[propertyId];
        require(foundProperty.owner != address(this), "Property does not have an owner");
        require(foundProperty.owner != player, "player cannot pay rent for self");

        uint256 rentAmount;

        // Check if the property is a Utility
        if (foundProperty.propertyType == MonopolyLibrary.PropertyType.Utility) {
            rentAmount = _checkUtilityRent(propertyId, diceRolled);
        }
        // Check if the property is a Rail Station
        else if (foundProperty.propertyType == MonopolyLibrary.PropertyType.RailStation) {
            rentAmount = _checkRailStationRent(propertyId);
        }
        // Regular Property Rent
        else {
            rentAmount = foundProperty.noOfUpgrades > 0
                ? foundProperty.rentAmount * (2 ** (foundProperty.noOfUpgrades - 1))
                : foundProperty.rentAmount;
        }

        uint8 proposalId = propertyToProposal[propertyId];
        if (proposalId > 0) {
            Proposal storage proposal = inGameProposals[proposalId];
            uint256 numberOfBenefits = proposal.numberOfBenefits;

            for (uint8 i = 0; i < numberOfBenefits; i++) {
                if (proposal.benefits[i].isActive) {
                    if (proposal.benefits[i].benefitType == BenefitType.FREE_RENT) {
                        rentAmount = 0;
                    } else if (proposal.benefits[i].benefitType == BenefitType.RENT_DISCOUNT) {
                        rentAmount = (rentAmount * proposal.benefits[i].benefitValue) / 100;
                    }
                    proposal.benefits[i].numberOfTurns -= 1;
                    proposal.benefits[i].numberOfTurns == 0 ? proposal.benefits[i].isActive = false : true;
                }
            }
        }

        // Ensure player has enough funds to pay rent
        require(balanceOf(player) >= rentAmount, "Insufficient funds to pay rent");

        // Transfer the rent to the owner
        bool success = transferFrom(player, foundProperty.owner, rentAmount);
        require(success, "Transfer failed");
    }

    /**
     * @dev looked this through , i think i am not getting the summation of the amount but formula is correct
     */

    // Function to mortgage a property
    function mortgageProperty(uint8 propertyId) external {
        MonopolyLibrary.PropertyG storage property = gameProperties[propertyId];
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
        MonopolyLibrary.PropertyG storage property = gameProperties[propertyId];

        require(property.owner == msg.sender, "You are not the owner of this property");
        require(mortgagedProperties[propertyId], "Property is not Mortgaged");

        // Transfer the repaid funds to the contract owner or use it for future logic
        bool success = transfer(address(this), property.buyAmount / 2);
        require(success, "Token transfer failed");

        // Release the mortgage
        mortgagedProperties[propertyId] = false;
    }

    /**
     * @dev It's important to note that only properties can be upgraded and down graded railstations and companies cannot
     *  a 2d mapping of string to address to number
     *  we can upgrade the three at once
     */
    function upgradeProperty(uint8 propertyId, uint8 _noOfUpgrade) external {
        MonopolyLibrary.PropertyG storage property = gameProperties[propertyId];

        require(property.owner == msg.sender, "You are not the owner of this property");
        require(!mortgagedProperties[propertyId], "Property is Mortgaged cannot upgrade");
        require(property.propertyType == MonopolyLibrary.PropertyType.Property, "Only properties can be upgraded");
        require(_noOfUpgrade > 0 && _noOfUpgrade <= 5, "");
        // require(noOfUpgrades[propertyId] <= 5, "Property at Max upgrade");

        uint8 mustOwnedNumberOfSiteColor = upgradeUserPropertyColorOwnedNumber[property.propertyColor];

        // Calculate the cost of one house
        uint8 userColorGroupOwned = noOfColorGroupOwnedByUser[property.propertyColor][msg.sender];

        require(userColorGroupOwned >= mustOwnedNumberOfSiteColor, "must own at least two site with same color ");
        require(property.noOfUpgrades < 5, "reach the peak upgrade for this property ");
        uint8 noOfUpgrade = property.noOfUpgrades + _noOfUpgrade;

        require(noOfUpgrade <= 5, "upgrade exceed peak ");

        uint256 amountToPay = property.buyAmount * (2 * (2 ** (noOfUpgrade - 1)));

        require(balanceOf(msg.sender) >= amountToPay, "Insufficient funds to upgrade property");

        bool success = transferFrom(msg.sender, address(this), amountToPay);

        require(success, "Insufficient funds to transfer");

        property.noOfUpgrades += 1;

        emit PropertyUpGraded(propertyId);
    }

    // make the game owner of the bank and hence owns the token
    function downgradeProperty(uint8 propertyId, uint8 noOfDowngrade) external {
        MonopolyLibrary.PropertyG memory property = gameProperties[propertyId];

        // Ensure the caller is the owner of the property
        require(property.owner == msg.sender, "You are not the owner of this property");
        require(property.noOfUpgrades > 0, "cannot downgrade site");
        require(noOfDowngrade > 0 && noOfDowngrade <= property.noOfUpgrades, "cannot downgrade");

        // Ensure the property is not mortgaged
        require(!mortgagedProperties[propertyId], "Cannot downgrade a mortgaged property");

        uint256 amountToRecieve = property.buyAmount * (2 ** (noOfDowngrade - 1));

        bool success = transfer(msg.sender, amountToRecieve);
        require(success, "");
        property.noOfUpgrades -= noOfDowngrade;
        emit PropertyDownGraded(propertyId);
    }

    // for testing purpose
    function bal(address addr) external view returns (uint256) {
        uint256 a = balanceOf(addr);
        return a;
    }


    function getProperty(uint8 propertyId) external view returns(MonopolyLibrary.PropertyG memory property){
         property = gameProperties[propertyId];
        return property;
    }
}
