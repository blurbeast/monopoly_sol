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
    }
    struct PropertyRent {
        uint8 propertyId;
        uint site;
        uint withOneHouse;
        uint withTwoHouses;
        uint withThreeHouses;
        uint withFourHouses;
        uint withHotel;
        uint costOfHouse;
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
        address user;
        // address biddedUser;
        uint8 proposedPropertyId;
        uint8 biddedPropertyId;
        uint256 biddedTokenAmount;
        mapping(uint8 => Benefit) benefits;
        uint8 numberOfBenefits;
    }

    struct Bid {
        address bidder;
        uint256 bidAmount;
    }

    struct PropertySwap {
        address bidder;
        address clientAddress;
        uint8 biddersProperty;
        uint8 yourProperty;
        SWAP_TYPE swapType;
        uint biddingAmount;
    }

    enum SWAP_TYPE {
        PROPERTY_FOR_PROPERTY,
        PROPERTY_FOR_CASH_AND_PROPERTY,
        PROPERTY_AND_CASH_FOR_PROPERTY,
        PROPERTY_FOR_CASH,
        CASH_FOR_PROPERTY
    }

    event PropertySwapProposed(
        address indexed proposer,
        address indexed proposee,
        uint8 biddingPropertyId,
        uint8 propertyToSwapId,
        SWAP_TYPE swapType
    );

    // Event to log the swap details
    event DealAccepted(
        address indexed user,
        address indexed bidder,
        uint8 biddersProperty,
        uint8 yourProperty,
        MonopolyLibrary.SWAP_TYPE swapType,
        uint256 biddingAmount
    );

    // Event for counter deal tracking
    event CounterDealProposed(
        address indexed user,
        uint8 biddingPropertyId,
        uint8 propertyToSwapId,
        MonopolyLibrary.SWAP_TYPE swapType,
        uint256 biddingAmount
    );

    event DealRejected(address indexed user);
}
