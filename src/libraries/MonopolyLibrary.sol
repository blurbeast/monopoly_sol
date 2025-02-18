//SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

library MonopolyLibrary {
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

    struct Property {
        bytes name;
        uint256 rentAmount;
        bytes uri;
        uint256 buyAmount;
        PropertyType propertyType;
        PropertyColors color;
    }

    struct Player {
        string username;
        address addr;
        uint8 playerCurrentPosition;
        bool inJail;
        uint8 jailAttemptCount;
        uint256 cash;
        uint8 diceRolled;
        bool bankrupt;
        uint256 netWorth;
    }

    struct PropertyRent {
        uint8 propertyId;
        uint256 site;
        uint256 withOneHouse;
        uint256 withTwoHouses;
        uint256 withThreeHouses;
        uint256 withFourHouses;
        uint256 withHotel;
        uint256 costOfHouse;
    }

    enum BenefitType {
        NONE,
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
        address player;
        address otherPlayer;
        SwapType swapType;
        ProposalStatus proposalStatus;
    }

    enum ProposalStatus {
        PENDING,
        ACCEPTED,
        REJECTED
    }

    struct PropertyForProperty {
        uint8 proposedPropertyId;
        uint8 biddingPropertyId;
    }

    struct PropertyForCashAndProperty {
        uint8 proposedPropertyId;
        uint8 biddingPropertyId;
        uint256 biddingAmount;
    }

    struct PropertyAndCashForProperty {
        uint8 proposedPropertyId;
        uint256 proposedAmount;
        uint8 biddingPropertyId;
    }

    struct PropertyForCash {
        uint8 propertyId;
        uint256 biddingAmount;
    }

    struct CashForProperty {
        uint256 proposedAmount;
        uint8 biddingPropertyId;
    }

    struct SwappedType {
        CashForProperty cashForProperty;
        PropertyForCash propertyForCash;
        PropertyAndCashForProperty propertyAndCashForProperty;
        PropertyForCashAndProperty propertyForCashAndProperty;
        PropertyForProperty propertyForProperty;
    }

    enum SwapType {
        PROPERTY_FOR_PROPERTY,
        PROPERTY_FOR_CASH_AND_PROPERTY,
        PROPERTY_AND_CASH_FOR_PROPERTY,
        PROPERTY_FOR_CASH,
        CASH_FOR_PROPERTY
    }

    struct PropertySwap {
        address bidder;
        address clientAddress;
        uint8 biddersProperty;
        uint8 yourProperty;
        SwapType swapType;
        uint256 biddingAmount;
    }

    event PropertySwapProposed(
        address indexed proposer,
        address indexed proposee,
        uint8 biddingPropertyId,
        uint8 propertyToSwapId,
        SwapType swapType
    );

    // Event to log the swap details
    event DealAccepted(
        address indexed user,
        address indexed bidder,
        uint8 biddersProperty,
        uint8 yourProperty,
        MonopolyLibrary.SwapType swapType,
        uint256 biddingAmount
    );

    // Event for counter deal tracking
    event CounterDealProposed(
        address indexed user,
        uint8 biddingPropertyId,
        uint8 propertyToSwapId,
        MonopolyLibrary.SwapType swapType,
        uint256 biddingAmount
    );

    event PropertyUpgraded(
        uint8 indexed propertyId,
        address indexed user,
        uint8 upgradesApplied,
        uint256 newRentAmount
    );

    event PropertyDowngraded(
        uint8 indexed propertyId,
        address indexed user,
        uint8 downgradesApplied,
        uint8 remainingUpgrades,
        uint256 refundAmount
    );

    event DealRejected(address indexed user);
}
