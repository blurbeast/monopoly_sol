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
}
