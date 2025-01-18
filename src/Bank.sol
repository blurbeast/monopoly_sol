//SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {ERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import {ReentrancyGuard} from "lib/openzeppelin-contracts/contracts/utils/ReentrancyGuard.sol";

import "./libraries/MonopolyLibrary.sol";
import {console} from "forge-std/Test.sol";

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
contract GameBank is ERC20("GameBank", "GB"), ReentrancyGuard {
    using MonopolyLibrary for MonopolyLibrary.PropertyG;
    using MonopolyLibrary for MonopolyLibrary.Property;
    using MonopolyLibrary for MonopolyLibrary.PropertyColors;
    using MonopolyLibrary for MonopolyLibrary.PropertyType;
    using MonopolyLibrary for MonopolyLibrary.BenefitType;
    using MonopolyLibrary for MonopolyLibrary.Benefit;
    using MonopolyLibrary for MonopolyLibrary.Proposal;

    MonopolyLibrary.PropertyG[] private properties;

    //    mapping(uint8 => MonopolyLibrary.Bid) public bids;
    mapping(uint8 => address) private propertyOwner;
    mapping(uint256 => bool) private mortgagedProperties;
    mapping(uint8 => uint8) private noOfUpgrades;

    uint16 private constant decimalPlace = 1000;
    //
    mapping(MonopolyLibrary.PropertyColors => mapping(address => uint8)) public noOfColorGroupOwnedByUser;
    mapping(MonopolyLibrary.PropertyColors => uint8) private upgradeUserPropertyColorOwnedNumber;

    event PropertyBid(uint8 indexed propertyId, address indexed bidder, uint256 bidAmount);
    event PropertySold(uint8 indexed propertyId, address indexed newOwner, uint256 amount);

    // the tolerance is the extra token minted to cater for player borrowing and community card picked .
    uint256 private constant tolerance = 4;
    NFTContract private nftContract;
    uint8 private propertySize;
    mapping(uint8 => MonopolyLibrary.PropertyG) public gameProperties;
    mapping(address => MonopolyLibrary.PropertySwap) propertySwap;

    /**
     * @dev Initializes the contract with a fixed supply of tokens.
     * @param numberOfPlayers the total number of players.
     * @dev _mint an internal function that mints the total token needed for the game.
     */
    constructor(uint8 numberOfPlayers, address _nftContract) {
        uint256 amountToMint = (numberOfPlayers + tolerance) * decimalPlace;

        require(_nftContract.code.length > 0, "not a contract address");
        nftContract = NFTContract(_nftContract);
        _mint(address(this), amountToMint);
        _gameProperties();
        _setNumberForColoredPropertyNumber();
    }

    function getNumberOfUserOwnedPropertyOnAColor(address user, MonopolyLibrary.PropertyColors color)
        external
        view
        returns (uint8)
    {
        return noOfColorGroupOwnedByUser[color][user];
    }

    function mint(address to, uint256 amount) external {
        _transfer(address(this), to, amount);
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

    // the front end should check if the property is owned by the bank or another player ,
    // if owned by the bank , a buy property button should be activated
    // if owned by another player , a rent button or make proposal or bid deal should be activated...

    // this function is only meant to interact with the bank .

    function buyProperty(uint8 propertyId, address buyer) external nonReentrant {
        MonopolyLibrary.PropertyG storage property = gameProperties[propertyId];
        require(property.propertyType != MonopolyLibrary.PropertyType.Special, "Invalid property, could not be bought");
        require(property.owner != buyer, "You already own the property");
        // require(property.buyAmount > 0, "Property price must be greater than zero");

        // when dealing with bank and property, the bank will only take what is said to be the actual amount
        // require(bidAmount >= property.buyAmount, "Bid amount must be at least the property price");

        require(balanceOf(buyer) >= property.buyAmount, "insufficient balance");

        // commented this out because even though a player mortagage property, he/she still retains the ownership
        // require(!mortgagedProperties[propertyId], "Property is Mortgaged and cannot be bought");
        require(property.owner == address(this), "already owned by a player");

        // // Approve contract to spend bid amount (requires user to call `approve` beforehand)
        // require(balanceOf(msg.sender) >= bidAmount, "Insufficient funds for bid");

        _transfer(buyer, address(this), property.buyAmount);

        // Update ownership and increment sales count
        property.owner = buyer;
        propertyOwner[propertyId] = buyer;

        //no need to reassign again as the previous read was from the state and it was said to be storage .
        // gameProperties[propertyId] = property;

        noOfColorGroupOwnedByUser[property.propertyColor][buyer] += 1;

        property.propertyType == MonopolyLibrary.PropertyType.RailStation ? numberOfOwnedRailways[buyer] += 1 : 0;

        // // Emit an event
    }

    mapping(uint256 => MonopolyLibrary.Proposal) public inGameProposals;
    mapping(uint8 => uint8) public propertyToProposal;
    uint256 private proposalIds;
    mapping(uint8 => MonopolyLibrary.SwappedType) public swappedType;

    //address proposer,
    //address proposee,
    //uint8 biddingPropertyId,
    //uint8 propertyToSwapId,
    //MonopolyLibrary.SwapType swapType,
    //uint256 biddingAmount

    function getProposalSwappedType(uint8 proposalId) external view returns(MonopolyLibrary.SwappedType memory ) {
        return swappedType[proposalId];
    }

    // correct i think
    function makeProposal(
        address proposer,
        address otherPlayer,
        uint8 proposedPropertyId,
        uint8 biddingPropertyId,
        MonopolyLibrary.SwapType swapType,
        uint256 amountInvolved
    ) external {
        // using tdd
        address realOwner = propertyOwner[proposedPropertyId];
        require(realOwner == proposer, "asset specified is not owned by player");
        require(!mortgagedProperties[proposedPropertyId], "asset on mortgage");

        proposalIds += 1;
        MonopolyLibrary.Proposal storage proposal = inGameProposals[proposalIds];
        proposal.swapType = swapType;
        proposal.otherPlayer = otherPlayer;
        proposal.player = proposer;

        proposal.swapType == MonopolyLibrary.SwapType.PROPERTY_FOR_PROPERTY ?
            _propertyForProperty(proposalIds, proposedPropertyId, biddingPropertyId) :
        swapType == MonopolyLibrary.SwapType.PROPERTY_FOR_CASH_AND_PROPERTY ?
            _propertyForCashAndProperty(proposalIds, proposedPropertyId, biddingPropertyId, amountInvolved)
        : swapType == MonopolyLibrary.SwapType.PROPERTY_AND_CASH_FOR_PROPERTY ?
            _propertyAndCashForProperty(proposalIds, proposedPropertyId, amountInvolved, biddingPropertyId)
        :
        swapType == MonopolyLibrary.SwapType.PROPERTY_FOR_CASH ?
            _propertyForCash(proposalIds, proposedPropertyId, amountInvolved) :
        swapType == MonopolyLibrary.SwapType.CASH_FOR_PROPERTY ?  
        _cashForProperty(proposalIds, amountInvolved, biddingPropertyId) : revert() ;


        // to emit an event here
    }

    function _cashForProperty(uint256 proposalId, uint256 proposedAmount, uint8 biddingPropertyId) private {
        MonopolyLibrary.SwappedType storage swappedSwapType = swappedType[proposalId];
        swappedSwapType.cashForProperty({
            proposedAmount : proposedAmount,
            biddingPropertyId : biddingPropertyId
        });
    }

    function _propertyForCash(uint256 proposalId, uint8 propertyId, uint256 biddingAmount) private {
        MonopolyLibrary.SwappedType storage swappedSwapType = swappedType[proposalId];
        swappedSwapType.propertyForCash({
            propertyId : propertyId,
            biddingAmount : biddingAmount
        });
    }

    function _propertyAndCashForProperty(uint256 proposailId, uint8 proposedPropertyId, uint256 proposedAmount, uint8 biddingPropertyId) private {
    MonopolyLibrary.SwappedType storage swappedSwapType = swappedType[proposalId];
    swappedSwapType.propertyAndCashForProperty ({
    proposedPropertyId : proposedPropertyId,
    proposedAmount : proposedAmount,
    biddingPropertyId : biddingPropertyId
    });
    }
    function _propertyForCashAndProperty(uint256 proposalId, uint8 proposedPropertyId, uint8 biddingPropertyId, uint8 biddingAmount) private view {
    MonopolyLibrary.SwappedType storage swappedSwapType = swappedType[proposalId];

    swappedSwapType.propertyForCashAndProperty({
    proposedPropertyId : propposedPropertyId,
    biddingPropertyId : biddingPropertyId,
    biddingAmount : biddingAmount
    });
    }
    function _propertyForProperty(uint256 proposalId, uint8 proposedPropertyId, uint8 biddingPropertyId) private view {
        MonopolyLibrary.SwappedType storage swappedSwapType = swappedType[proposalId];
        swappedSwapType.propertyForProperty({
    proposedPropertyId : proposedPropertyId,
    biddingPropertyId : biddingPropertyId
    });
    }

    // in progress
    // this state track the user to the proposalId to a boolean value
    mapping(uint8 => mapping(address => bool)) private userProposalExist;

    function acceptProposal(address _user, uint8 proposalId) external nonReentrant {
        MonopolyLibrary.Proposal storage proposal = inGameProposals[proposalId];

        address realOwner = propertyOwner[1];

        require(realOwner == _user, "only owner can perform action");
        require(!mortgagedProperties[1], "property is on mortgage");

        if (1 > 0) {
            require(balanceOf(proposal.player) >= 0, "");

            _transfer(proposal.player, _user, 2);
        }

        uint8 sizeOfBenefits = uint8(1);

        //        for (uint8 i = 0; i < sizeOfBenefits; i++) {
        //            proposal.benefits[i].isActive = true;
        //        }

        // make changes to the property
        // i think refactoring the property struct will be okay here as we should only read from the state here
        // here the owner is vague as it would cost more here
        // the mapping propertyOwner handles this
        // moving on it should be changed

        MonopolyLibrary.PropertyG storage property = gameProperties[1];
        property.owner = proposal.player;

        //        propertyOwner[proposal.biddingPropertyId] = proposal.player;
        //        propertyOwner[proposal.proposedPropertyId] = realOwner;

        MonopolyLibrary.PropertyG storage proposedProperty = gameProperties[1];
        proposedProperty.owner = realOwner;

        // change the color number for each property
        noOfColorGroupOwnedByUser[property.propertyColor][realOwner] -= 1;
        noOfColorGroupOwnedByUser[property.propertyColor][proposal.player] += 1;

        noOfColorGroupOwnedByUser[proposedProperty.propertyColor][realOwner] += 1;
        noOfColorGroupOwnedByUser[proposedProperty.propertyColor][proposal.player] -= 1;

        //confirm if it is a rail station
        property.propertyType == MonopolyLibrary.PropertyType.RailStation
            ? numberOfOwnedRailways[proposal.player] += 1
            : numberOfOwnedRailways[realOwner] -= 1;

        proposedProperty.propertyType == MonopolyLibrary.PropertyType.RailStation
            ? numberOfOwnedRailways[realOwner] += 1
            : numberOfOwnedRailways[proposal.player] -= 1;

        propertyToProposal[1] = proposalId;
        userProposalExist[proposalId][_user] = true;
        // to emit an event here
    }

    mapping(address => uint8) private numberOfOwnedRailways;

    function _checkRailStationRent(uint8 propertyId) private view returns (uint256) {
        console.log("property id is ::: ", propertyId);
        address railOwner = propertyOwner[propertyId];
        console.log("address of owner is ::: ", railOwner);
        // Count how many railway stations are owned by the player
        uint8 ownedRailways = numberOfOwnedRailways[railOwner];
        console.log("owned number of rail is ::: ", ownedRailways);

        return 25 * (2 ** (ownedRailways - 1));
    }

    function _checkUtilityRent(uint8 propertyId, uint256 diceRolled) private view returns (uint256) {
        require(propertyId == 13 || propertyId == 29, "");

        return propertyOwner[13] == propertyOwner[29] ? (diceRolled * 10) : (diceRolled * 4);
    }

    function handleRent(address player, uint8 propertyId, uint8 diceRolled) external nonReentrant {
        // require(propertyId <= propertySize, "No property with the given ID");
        require(!mortgagedProperties[propertyId], "Property is Mortgaged no rent");
        MonopolyLibrary.PropertyG storage foundProperty = gameProperties[propertyId];
        // are we paying for special properties ?
        require(foundProperty.owner != address(this), "Property does not have an owner");
        require(foundProperty.owner != player, "Player Owns Property no need for rent");

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
        //        if (proposalId > 0) {
        //            bool isAnActiveProposal = userProposalExist[proposalId][player];
        //            if (isAnActiveProposal) {
        //                MonopolyLibrary.Proposal storage proposal = inGameProposals[proposalId];
        ////                uint256 numberOfBenefits = proposal.numberOfBenefits;
        //
        //                for (uint8 i = 0; i < numberOfBenefits; i++) {
        //                    if (proposal.benefits[i].isActive) {
        //                        if (proposal.benefits[i].benefitType == MonopolyLibrary.BenefitType.FREE_RENT) {
        //                            rentAmount = 0;
        //                        } else if (proposal.benefits[i].benefitType == MonopolyLibrary.BenefitType.RENT_DISCOUNT) {
        //                            rentAmount = (rentAmount * proposal.benefits[i].benefitValue) / 100;
        //                        }
        //                        proposal.benefits[i].numberOfTurns -= 1;
        //                        proposal.benefits[i].numberOfTurns == 0 ? proposal.benefits[i].isActive = false : true;
        //                    }
        //                }
        //            }
        //        }

        // Transfer the rent to the owner
                _transfer(player, foundProperty.owner, rentAmount);
    }

    // love the enum swap type
    function proposePropertySwap(
        address proposer,
        address proposee,
        uint8 biddingPropertyId,
        uint8 propertyToSwapId,
        MonopolyLibrary.SwapType swapType,
        uint256 biddingAmount
    ) public {
        // Validate the bidding property
        MonopolyLibrary.PropertyG storage biddingProperty = gameProperties[biddingPropertyId];

        // Ensure proposer and proposee are different
        require(proposer != proposee, "Proposer and proposee cannot be the same");
        if (biddingPropertyId != 0) {
            require(biddingProperty.owner == proposer, "You are not the owner of this property");
            require(!mortgagedProperties[biddingPropertyId], "Property is already mortgaged");
        }

        // Validate the replacement property
        if (swapType != MonopolyLibrary.SwapType.CASH_FOR_PROPERTY) {
            MonopolyLibrary.PropertyG storage propertyToSwap = gameProperties[propertyToSwapId];
            require(propertyToSwap.owner == proposee, "Proposee does not own the replacement property");
        }

        // Validate swap type (if required) WILL BE DONE IN FRONTEND
        // require(swapType >= 0 && swapType <= 2, "Invalid swap type");

        // Create or update the swap proposal
        MonopolyLibrary.PropertySwap storage swap = propertySwap[proposee];

        swap.bidder = proposer;
        swap.biddersProperty = biddingPropertyId;
        swap.yourProperty = propertyToSwapId;
        swap.swapType = swapType;
        swap.biddingAmount = biddingAmount;
        swap.clientAddress = proposee;

        // Emit event for off-chain tracking
        emit MonopolyLibrary.PropertySwapProposed(proposer, proposee, biddingPropertyId, propertyToSwapId, swapType);
    }

    function acceptDeal(address user) external nonReentrant {
        // Retrieve the deal for the user

        MonopolyLibrary.PropertySwap storage deal = propertySwap[user];
        require(deal.bidder != address(0), "No deal exists for this user");

        // Retrieve the properties involved in the deal
        MonopolyLibrary.PropertyG storage biddingProperty = gameProperties[deal.biddersProperty];
        MonopolyLibrary.PropertyG storage userProperty = gameProperties[deal.yourProperty];

        // Validate ownership of the properties
        if (deal.biddersProperty != 0) {
            require(biddingProperty.owner == deal.bidder, "Bidder is not the owner of the bidding property");
        }

        if (deal.yourProperty != 0) {
            require(userProperty.owner == user, "You do not own the property being swapped");
        }

        // Handle the swap based on its type
        if (deal.swapType == MonopolyLibrary.SwapType.PROPERTY_FOR_PROPERTY) {
            // Swap ownership of the properties 1 MEANS THERE IS PROPERTY SWAP IN updateOwnershipAndAttributes
            updateOwnershipAndAttributes(biddingProperty, userProperty, user, deal.bidder, 1);
        } else if (deal.swapType == MonopolyLibrary.SwapType.PROPERTY_FOR_CASH) {
            // Transfer cash to the bidder and transfer ownership to the user
            require(deal.biddingAmount > 0, "Invalid bidding amount");
            _transfer(deal.bidder, user, deal.biddingAmount);
            // 2 MEANS THERE IS NO PROPERTY SWAP IN updateOwnershipAndAttributes USER TRANSFERS PROPERTY TO CLIENT
            updateOwnershipAndAttributes(biddingProperty, userProperty, user, deal.bidder, 2);
        } else if (deal.swapType == MonopolyLibrary.SwapType.CASH_FOR_PROPERTY) {
            // Transfer cash to the user and transfer ownership to the bidder
            require(deal.biddingAmount > 0, "Invalid bidding amount");
            _transfer(user, biddingProperty.owner, deal.biddingAmount);
            //  MEANS THERE IS NO PROPERTY SWAP IN updateOwnershipAndAttributes USER GIVES CASH AND RECEIVE PROPERTY FROM CLIENT
            updateOwnershipAndAttributes(userProperty, biddingProperty, user, user, 3);
        } else if (deal.swapType == MonopolyLibrary.SwapType.PROPERTY_AND_CASH_FOR_PROPERTY) {
            // Transfer cash from the bidder to the user and swap ownership
            require(deal.biddingAmount > 0, "Invalid bidding amount");
            _transfer(biddingProperty.owner, user, deal.biddingAmount);
            updateOwnershipAndAttributes(userProperty, biddingProperty, deal.bidder, user, 1);
        } else if (deal.swapType == MonopolyLibrary.SwapType.PROPERTY_FOR_CASH_AND_PROPERTY) {
            // Transfer cash from the user to the bidder and swap ownership
            require(deal.biddingAmount > 0, "Invalid bidding amount");
            _transfer(user, biddingProperty.owner, deal.biddingAmount);
            updateOwnershipAndAttributes(biddingProperty, userProperty, user, deal.bidder, 1);
        } else {
            revert("Invalid swap type");
        }

        // Emit an event to log the accepted deal
        emit MonopolyLibrary.DealAccepted(
            user, deal.bidder, deal.biddersProperty, deal.yourProperty, deal.swapType, deal.biddingAmount
        );

        // Clear the deal after processing
        delete propertySwap[user];
    }

    function updateOwnershipAndAttributes(
        MonopolyLibrary.PropertyG storage userProperty,
        MonopolyLibrary.PropertyG storage biddersProperty,
        address newOwner1,
        address newOwner2,
        uint8 typeOf
    ) internal {
        // Update color group ownership
        // this was commented out because it has been updated in the buy property function , hence redundancy is not allowed
        //

        // if(noOfColorGroupOwnedByUser[userProperty.propertyColor][userProperty.owner] !=0 ) {
        // noOfColorGroupOwnedByUser[userProperty.propertyColor][userProperty.owner] -= 1;
        // }

        noOfColorGroupOwnedByUser[userProperty.propertyColor][userProperty.owner] -= 1;
        noOfColorGroupOwnedByUser[userProperty.propertyColor][newOwner1] += 1;

        // if( noOfColorGroupOwnedByUser[biddersProperty.propertyColor][biddersProperty.owner] != 0){

        noOfColorGroupOwnedByUser[biddersProperty.propertyColor][biddersProperty.owner] -= 1;
        // }
        noOfColorGroupOwnedByUser[biddersProperty.propertyColor][newOwner2] += 1;

        // Handle rail station ownership changes
        if (
            (userProperty.propertyType == MonopolyLibrary.PropertyType.RailStation)
                && (numberOfOwnedRailways[userProperty.owner] != 0)
        ) {
            numberOfOwnedRailways[userProperty.owner] -= 1;
        } else {
            numberOfOwnedRailways[newOwner1] += 1;
        }

        if (
            (biddersProperty.propertyType == MonopolyLibrary.PropertyType.RailStation)
                && (numberOfOwnedRailways[biddersProperty.owner] != 0)
        ) {
            {
                numberOfOwnedRailways[biddersProperty.owner] -= 1;
            }
            numberOfOwnedRailways[newOwner2] += 1;
        }

        if (typeOf == 1) {
            // Swap ownership

            userProperty.owner = newOwner1;
            biddersProperty.owner = newOwner2;
        } else if (typeOf == 2) {
            biddersProperty.owner = newOwner2;
        } else if (typeOf == 3) {
            biddersProperty.owner = newOwner1;
        } else {
            revert();
        }
    }

    function rejectDeal(address user) external nonReentrant {
        // Retrieve the deal for the user
        MonopolyLibrary.PropertySwap storage deal = propertySwap[user];
        require(deal.bidder != address(0), "No deal exists for this user");

        // Clear the deal after it is processed
        delete propertySwap[user];

        // Emit event for off-chain tracking
        emit MonopolyLibrary.DealRejected(user);
    }

    function returnProposal(address user) external view returns (MonopolyLibrary.PropertySwap memory) {
        MonopolyLibrary.PropertySwap memory deal = propertySwap[user];
        return deal;
    }

    function counterDeal(
        address user,
        uint8 biddingPropertyId,
        uint8 propertyToSwapId,
        MonopolyLibrary.SwapType swapType,
        uint256 biddingAmount
    ) external nonReentrant {
        // Retrieve the deal for the user
        MonopolyLibrary.PropertySwap storage deal = propertySwap[user];
        address reverseClient = deal.bidder;
        require(deal.bidder != address(0), "No deal exists for this user");

        // Check if the caller is authorized
        require(msg.sender != deal.clientAddress, "Unauthorized caller");

        // Retrieve properties involved in the deal
        MonopolyLibrary.PropertyG storage userProperty = gameProperties[deal.yourProperty];
        MonopolyLibrary.PropertyG storage biddingProperty = gameProperties[biddingPropertyId];

        // Ensure the properties are owned by the correct parties
        require(userProperty.owner == user, "User does not own the proposed property");
        if (biddingPropertyId != 0) {
            require(biddingProperty.owner == deal.clientAddress, "Caller does not own the bidding property");
        }

        // Delete the previous deal to avoid conflicts
        delete propertySwap[user];

        // Propose the counter deal
        proposePropertySwap(user, reverseClient, propertyToSwapId, biddingPropertyId, swapType, biddingAmount);

        // Emit event for transparency
        emit MonopolyLibrary.CounterDealProposed(user, propertyToSwapId, biddingPropertyId, swapType, biddingAmount);
    }

    /**
     * @dev looked this through , i think i am not getting the summation of the amount but formula is correct
     */

    // Function to mortgage a property
    function mortgageProperty(uint8 propertyId, address player) external nonReentrant {
        MonopolyLibrary.PropertyG memory property = gameProperties[propertyId];
        require(!mortgagedProperties[propertyId], "Property is already Mortgaged");

        require(property.owner == player, "You are not the owner of this property");
        mortgagedProperties[propertyId] = true;

        uint256 mortgageAmount = property.buyAmount / 2;
        // Transfer funds to the owner
        //        bool success = transferFrom(address(this), msg.sender, mortgageAmount);
        //        require(success, "Token transfer failed");
        _transfer(address(this), player, mortgageAmount);

        emit PropertyMortgaged(propertyId, mortgageAmount, player);
    }

    // Function to release a mortgage
    function releaseMortgage(uint8 propertyId, address player) external {
        MonopolyLibrary.PropertyG memory property = gameProperties[propertyId];

        require(property.owner == player, "You are not the owner of this property");
        require(mortgagedProperties[propertyId], "Property is not Mortgaged");

        // Transfer the repaid funds to the contract owner or use it for future logic

        _transfer(player, address(this), (property.buyAmount / 2));

        // Release the mortgage
        mortgagedProperties[propertyId] = false;
    }

    /**
     * @dev It's important to note that only properties can be upgraded and down graded railstations and companies cannot
     *  a 2d mapping of string to address to number
     *  we can upgrade the three at once
     */
    function upgradeProperty(uint8 propertyId, uint8 _noOfUpgrade, address player) external {
        MonopolyLibrary.PropertyG storage property = gameProperties[propertyId];

        require(property.owner == player, "You are not the owner of this property");
        require(!mortgagedProperties[propertyId], "Property is Mortgaged cannot upgrade");
        require(property.propertyType == MonopolyLibrary.PropertyType.Property, "Only properties can be upgraded");
        require(_noOfUpgrade > 0 && _noOfUpgrade <= 5, "");
        // require(noOfUpgrades[propertyId] <= 5, "Property at Max upgrade");

        uint8 mustOwnedNumberOfSiteColor = upgradeUserPropertyColorOwnedNumber[property.propertyColor];

        // Calculate the cost of one house
        uint8 userColorGroupOwned = noOfColorGroupOwnedByUser[property.propertyColor][player];

        require(userColorGroupOwned >= mustOwnedNumberOfSiteColor, "must own at least two/three site with same color ");
        require(property.noOfUpgrades < 5, "reach the peak upgrade for this property ");
        uint8 noOfUpgrade = property.noOfUpgrades + _noOfUpgrade;

        require(noOfUpgrade <= 5, "upgrade exceed peak ");

        uint256 amountToPay = property.buyAmount * (2 * (2 ** (noOfUpgrade - 1)));

        require(balanceOf(player) >= amountToPay, "Insufficient funds to upgrade property");

        //        bool success = transferFrom(msg.sender, address(this), amountToPay);
        _transfer(player, address(this), amountToPay);

        property.noOfUpgrades += _noOfUpgrade;

        emit PropertyUpGraded(propertyId);
    }

    // make the game owner of the bank and hence owns the token
    function downgradeProperty(uint8 propertyId, uint8 noOfDowngrade, address player) external {
        MonopolyLibrary.PropertyG storage property = gameProperties[propertyId];

        // Ensure the caller is the owner of the property
        require(property.owner == player, "You are not the owner of this property");
        require(property.noOfUpgrades > 0, "cannot downgrade site");
        require(noOfDowngrade > 0 && noOfDowngrade <= property.noOfUpgrades, "cannot downgrade");

        // Ensure the property is not mortgaged
        require(!mortgagedProperties[propertyId], "Cannot downgrade a mortgaged property");

        uint256 amountToReceive = property.buyAmount * (2 ** (noOfDowngrade - 1));

        //        bool success = transfer(msg.sender, amountToReceive);
        //        require(success, "");
        _transfer(address(this), player, amountToReceive);

        property.noOfUpgrades -= noOfDowngrade;
        emit PropertyDownGraded(propertyId);
    }

    // for testing purpose
    function bal(address addr) external view returns (uint256) {
        uint256 a = balanceOf(addr);
        return a;
    }

    function getProperty(uint8 propertyId) external view returns (MonopolyLibrary.PropertyG memory property) {
        property = gameProperties[propertyId];
        return property;
    }

    function getPropertyOwner(uint8 propertyId) external view returns (address _propertyOwner) {
        MonopolyLibrary.PropertyG memory property = gameProperties[propertyId];
        _propertyOwner = property.owner;
        return _propertyOwner;
    }

    function viewDeals(address myDeals) public view returns (MonopolyLibrary.PropertySwap memory currentDeal) {
        MonopolyLibrary.PropertySwap storage swap = propertySwap[myDeals];
        currentDeal = swap;
        return currentDeal;
    }
}
