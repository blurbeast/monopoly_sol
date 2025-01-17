//SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "lib/openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "./libraries/MonopolyLibrary.sol";

/**
 *     @dev this is the generalized version of NFT contract.
 *     @notice this is a generalized version of NFT contract that can be used for any ERC721 token.
 *     @dev this contract has the total supply of 30 NFT to be used across all the games played on this platform.
 *     @dev Each NFT has a unique tokenId, and the tokenId is mapped to the owner's address.
 *     @dev The mint function is used to create new NFTs which is not more than 40 .
 *     @dev this contract is called upon on every new game created and it NFT URI is sent to the bank contract which then creates a property for each of the NFTs.
 *     @dev the URI of each NFT is fetched from the bank contract using the tokenId.
 */
contract GeneralNFT is ERC721URIStorage {
    uint8 public constant MAX_SUPPLY = 40;
    uint8 public totalSupply;
    string private baseUri;

    using MonopolyLibrary for MonopolyLibrary.Property;
    using MonopolyLibrary for MonopolyLibrary.PropertyColors;
    using MonopolyLibrary for MonopolyLibrary.PropertyType;

    struct Property {
        bytes name;
        uint256 rentAmount;
        bytes uri;
        uint256 buyAmount;
        PropertyType propertyType;
        PropertyColors color;
    }

    enum PropertyType {
        Property,
        RailStation,
        Utility,
        Special
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

    MonopolyLibrary.Property[] public allProperties;

    // Property[] private properties = new Property[](MAX_SUPPLY);
    mapping(uint8 => MonopolyLibrary.Property) private properties;

    mapping(uint8 => MonopolyLibrary.PropertyRent) propertyRent;

    constructor(string memory uri) ERC721("MonoPoly", "MNP") {
        baseUri = uri;
        createNftProperties();
        populateRent();
        _setAllProperties();
    }

    function mint(address _minter) external {
        require(totalSupply < MAX_SUPPLY, "Max supply reached");
        uint256 tokenId = totalSupply;
        _mint(_minter, tokenId);
        string memory tokenUri = string(abi.encodePacked(baseUri, "/", Strings.toString(tokenId)));
        _setTokenURI(tokenId, tokenUri);
        totalSupply++;
        populatePropertyUri();
    }

    function createNftProperties() private {
        properties[1] = MonopolyLibrary.Property({
            name: "GO",
            rentAmount: 0,
            uri: "",
            buyAmount: 0,
            propertyType: MonopolyLibrary.PropertyType.Special,
            color: MonopolyLibrary.PropertyColors.PURPLE
        });

        // Brown Properties
        properties[2] = MonopolyLibrary.Property({
            name: "Mediterranean Avenue",
            rentAmount: 2,
            uri: "",
            buyAmount: 60,
            propertyType: MonopolyLibrary.PropertyType.Property,
            color: MonopolyLibrary.PropertyColors.BROWN
        });

        properties[3] = MonopolyLibrary.Property({
            name: "Community Chest 1",
            rentAmount: 0,
            uri: "",
            buyAmount: 0,
            propertyType: MonopolyLibrary.PropertyType.Special,
            color: MonopolyLibrary.PropertyColors.PURPLE
        });

        properties[4] = MonopolyLibrary.Property({
            name: "Baltic Avenue",
            rentAmount: 4,
            uri: "",
            buyAmount: 80,
            propertyType: MonopolyLibrary.PropertyType.Property,
            color: MonopolyLibrary.PropertyColors.BROWN
        });

        properties[5] = MonopolyLibrary.Property({
            name: "Income Tax",
            rentAmount: 0,
            uri: "",
            buyAmount: 0,
            propertyType: MonopolyLibrary.PropertyType.Special,
            color: MonopolyLibrary.PropertyColors.PURPLE
        });

        properties[6] = MonopolyLibrary.Property({
            name: "Reading Railroad",
            rentAmount: 25,
            uri: "",
            buyAmount: 200,
            propertyType: MonopolyLibrary.PropertyType.RailStation,
            color: MonopolyLibrary.PropertyColors.PURPLE
        });

        // Light Blue Properties
        properties[7] = MonopolyLibrary.Property({
            name: "Connecticut Avenue",
            rentAmount: 8,
            uri: "",
            buyAmount: 120,
            propertyType: MonopolyLibrary.PropertyType.Property,
            color: MonopolyLibrary.PropertyColors.BLUE
        });

        properties[8] = MonopolyLibrary.Property({
            name: "Chance 1",
            rentAmount: 0,
            uri: "",
            buyAmount: 0,
            propertyType: MonopolyLibrary.PropertyType.Special,
            color: MonopolyLibrary.PropertyColors.PURPLE
        });

        properties[9] = MonopolyLibrary.Property({
            name: "Vermont Avenue",
            rentAmount: 6,
            uri: "",
            buyAmount: 100,
            propertyType: MonopolyLibrary.PropertyType.Property,
            color: MonopolyLibrary.PropertyColors.BLUE
        });

        properties[10] = MonopolyLibrary.Property({
            name: "Oriental Avenue",
            rentAmount: 6,
            uri: "",
            buyAmount: 100,
            propertyType: MonopolyLibrary.PropertyType.Property,
            color: MonopolyLibrary.PropertyColors.BLUE
        });

        properties[11] = MonopolyLibrary.Property({
            name: "Jail",
            rentAmount: 0,
            uri: "",
            buyAmount: 0,
            propertyType: MonopolyLibrary.PropertyType.Special,
            color: MonopolyLibrary.PropertyColors.PURPLE
        });

        // Pink Properties
        properties[12] = MonopolyLibrary.Property({
            name: "St. Charles Place",
            rentAmount: 10,
            uri: "",
            buyAmount: 140,
            propertyType: MonopolyLibrary.PropertyType.Property,
            color: MonopolyLibrary.PropertyColors.PINK
        });

        properties[13] = MonopolyLibrary.Property({
            name: "Electric Company",
            rentAmount: 0,
            uri: "",
            buyAmount: 150,
            propertyType: MonopolyLibrary.PropertyType.Utility,
            color: MonopolyLibrary.PropertyColors.PURPLE
        });

        properties[14] = MonopolyLibrary.Property({
            name: "States Avenue",
            rentAmount: 10,
            uri: "",
            buyAmount: 140,
            propertyType: MonopolyLibrary.PropertyType.Property,
            color: MonopolyLibrary.PropertyColors.PINK
        });

        properties[15] = MonopolyLibrary.Property({
            name: "Virginia Avenue",
            rentAmount: 12,
            uri: "",
            buyAmount: 160,
            propertyType: MonopolyLibrary.PropertyType.Property,
            color: MonopolyLibrary.PropertyColors.PINK
        });

        properties[16] = MonopolyLibrary.Property({
            name: "Pennsylvania Railroad",
            rentAmount: 25,
            uri: "",
            buyAmount: 200,
            propertyType: MonopolyLibrary.PropertyType.RailStation,
            color: MonopolyLibrary.PropertyColors.PURPLE
        });

        // Orange Properties
        properties[17] = MonopolyLibrary.Property({
            name: "St. James Place",
            rentAmount: 14,
            uri: "",
            buyAmount: 180,
            propertyType: MonopolyLibrary.PropertyType.Property,
            color: MonopolyLibrary.PropertyColors.ORANGE
        });

        properties[18] = MonopolyLibrary.Property({
            name: "Community Chest 2",
            rentAmount: 0,
            uri: "",
            buyAmount: 0,
            propertyType: MonopolyLibrary.PropertyType.Special,
            color: MonopolyLibrary.PropertyColors.PURPLE
        });

        properties[19] = MonopolyLibrary.Property({
            name: "Tennessee Avenue",
            rentAmount: 14,
            uri: "",
            buyAmount: 180,
            propertyType: MonopolyLibrary.PropertyType.Property,
            color: MonopolyLibrary.PropertyColors.ORANGE
        });

        properties[20] = MonopolyLibrary.Property({
            name: "New York Avenue",
            rentAmount: 16,
            uri: "",
            buyAmount: 200,
            propertyType: MonopolyLibrary.PropertyType.Property,
            color: MonopolyLibrary.PropertyColors.ORANGE
        });

        properties[21] = MonopolyLibrary.Property({
            name: "Free Parking",
            rentAmount: 0,
            uri: "",
            buyAmount: 0,
            propertyType: MonopolyLibrary.PropertyType.Special,
            color: MonopolyLibrary.PropertyColors.PURPLE
        });

        // Red Properties
        properties[22] = MonopolyLibrary.Property({
            name: "Kentucky Avenue",
            rentAmount: 18,
            uri: "",
            buyAmount: 220,
            propertyType: MonopolyLibrary.PropertyType.Property,
            color: MonopolyLibrary.PropertyColors.RED
        });

        properties[23] = MonopolyLibrary.Property({
            name: "Chance 2",
            rentAmount: 0,
            uri: "",
            buyAmount: 0,
            propertyType: MonopolyLibrary.PropertyType.Special,
            color: MonopolyLibrary.PropertyColors.PURPLE
        });

        properties[24] = MonopolyLibrary.Property({
            name: "Indiana Avenue",
            rentAmount: 18,
            uri: "",
            buyAmount: 220,
            propertyType: MonopolyLibrary.PropertyType.Property,
            color: MonopolyLibrary.PropertyColors.RED
        });

        properties[25] = MonopolyLibrary.Property({
            name: "Illinois Avenue",
            rentAmount: 20,
            uri: "",
            buyAmount: 240,
            propertyType: MonopolyLibrary.PropertyType.Property,
            color: MonopolyLibrary.PropertyColors.RED
        });

        properties[26] = MonopolyLibrary.Property({
            name: "B&O Railroad",
            rentAmount: 25,
            uri: "",
            buyAmount: 200,
            propertyType: MonopolyLibrary.PropertyType.RailStation,
            color: MonopolyLibrary.PropertyColors.PURPLE
        });

        // Yellow Properties
        properties[27] = MonopolyLibrary.Property({
            name: "Atlantic Avenue",
            rentAmount: 22,
            uri: "",
            buyAmount: 260,
            propertyType: MonopolyLibrary.PropertyType.Property,
            color: MonopolyLibrary.PropertyColors.YELLOW
        });

        properties[28] = MonopolyLibrary.Property({
            name: "Ventnor Avenue",
            rentAmount: 22,
            uri: "",
            buyAmount: 260,
            propertyType: MonopolyLibrary.PropertyType.Property,
            color: MonopolyLibrary.PropertyColors.YELLOW
        });

        properties[29] = MonopolyLibrary.Property({
            name: "Water Works",
            rentAmount: 0,
            uri: "",
            buyAmount: 150,
            propertyType: MonopolyLibrary.PropertyType.Utility,
            color: MonopolyLibrary.PropertyColors.PURPLE
        });

        properties[30] = MonopolyLibrary.Property({
            name: "Marvin Gardens",
            rentAmount: 24,
            uri: "",
            buyAmount: 280,
            propertyType: MonopolyLibrary.PropertyType.Property,
            color: MonopolyLibrary.PropertyColors.YELLOW
        });

        properties[31] = MonopolyLibrary.Property({
            name: "Go To Jail",
            rentAmount: 0,
            uri: "",
            buyAmount: 0,
            propertyType: MonopolyLibrary.PropertyType.Special,
            color: MonopolyLibrary.PropertyColors.PURPLE
        });

        // Green Properties
        properties[32] = MonopolyLibrary.Property({
            name: "Pacific Avenue",
            rentAmount: 26,
            uri: "",
            buyAmount: 300,
            propertyType: MonopolyLibrary.PropertyType.Property,
            color: MonopolyLibrary.PropertyColors.GREEN
        });

        properties[33] = MonopolyLibrary.Property({
            name: "North Carolina Avenue",
            rentAmount: 26,
            uri: "",
            buyAmount: 300,
            propertyType: MonopolyLibrary.PropertyType.Property,
            color: MonopolyLibrary.PropertyColors.GREEN
        });

        properties[34] = MonopolyLibrary.Property({
            name: "Community Chest 3",
            rentAmount: 0,
            uri: "",
            buyAmount: 0,
            propertyType: MonopolyLibrary.PropertyType.Special,
            color: MonopolyLibrary.PropertyColors.PURPLE
        });

        properties[35] = MonopolyLibrary.Property({
            name: "Pennsylvania Avenue",
            rentAmount: 28,
            uri: "",
            buyAmount: 320,
            propertyType: MonopolyLibrary.PropertyType.Property,
            color: MonopolyLibrary.PropertyColors.GREEN
        });

        properties[36] = MonopolyLibrary.Property({
            name: "Short Line",
            rentAmount: 25,
            uri: "",
            buyAmount: 200,
            propertyType: MonopolyLibrary.PropertyType.RailStation,
            color: MonopolyLibrary.PropertyColors.PURPLE
        });

        properties[37] = MonopolyLibrary.Property({
            name: "Chance 3",
            rentAmount: 0,
            uri: "",
            buyAmount: 0,
            propertyType: MonopolyLibrary.PropertyType.Special,
            color: MonopolyLibrary.PropertyColors.PURPLE
        });

        // Dark Blue Properties
        properties[38] = MonopolyLibrary.Property({
            name: "Park Place",
            rentAmount: 35,
            uri: "",
            buyAmount: 350,
            propertyType: MonopolyLibrary.PropertyType.Property,
            color: MonopolyLibrary.PropertyColors.BLUE
        });

        properties[39] = MonopolyLibrary.Property({
            name: "Luxury Tax",
            rentAmount: 0,
            uri: "",
            buyAmount: 0,
            propertyType: MonopolyLibrary.PropertyType.Special,
            color: MonopolyLibrary.PropertyColors.PURPLE
        });

        properties[40] = MonopolyLibrary.Property({
            name: "Boardwalk",
            rentAmount: 50,
            uri: "",
            buyAmount: 400,
            propertyType: MonopolyLibrary.PropertyType.Property,
            color: MonopolyLibrary.PropertyColors.BLUE
        });
    }

    function populatePropertyUri() private {
        require(totalSupply > 0, "no property minted yet");
        for (uint8 i = 1; i <= totalSupply; i++) {
            string memory onChainUri = tokenURI(i);
            MonopolyLibrary.Property storage property = properties[i];
            property.uri = bytes(onChainUri);
        }
    }

    function getAllProperties() external view returns (MonopolyLibrary.Property[] memory) {
        MonopolyLibrary.Property[] memory propertiesInMemory = new MonopolyLibrary.Property[](allProperties.length);
        for (uint256 i = 0; i < allProperties.length; i++) {
            propertiesInMemory[i] = allProperties[i];
        }
        return propertiesInMemory;
    }

    function _setAllProperties() private {
        for (uint8 i = 1; i < 40; i++) {
            allProperties.push(properties[i]);
        }
    }

    function populateRent() public {
        propertyRent[2] = MonopolyLibrary.PropertyRent({
            propertyId: 2,
            site: 2,
            withOneHouse: 10,
            withTwoHouses: 30,
            withThreeHouses: 90,
            withFourHouses: 160,
            withHotel: 250,
            costOfHouse: 50
        });

        propertyRent[4] = MonopolyLibrary.PropertyRent({
            propertyId: 4,
            site: 4,
            withOneHouse: 20,
            withTwoHouses: 60,
            withThreeHouses: 180,
            withFourHouses: 320,
            withHotel: 450,
            costOfHouse: 50
        });
        propertyRent[7] = MonopolyLibrary.PropertyRent({
            propertyId: 7,
            site: 6,
            withOneHouse: 30,
            withTwoHouses: 90,
            withThreeHouses: 270,
            withFourHouses: 400,
            withHotel: 550,
            costOfHouse: 50
        });

        propertyRent[9] = MonopolyLibrary.PropertyRent({
            propertyId: 9,
            site: 6,
            withOneHouse: 50,
            withTwoHouses: 90,
            withThreeHouses: 270,
            withFourHouses: 400,
            withHotel: 550,
            costOfHouse: 50
        });
        propertyRent[10] = MonopolyLibrary.PropertyRent({
            propertyId: 10,
            site: 8,
            withOneHouse: 40,
            withTwoHouses: 100,
            withThreeHouses: 300,
            withFourHouses: 450,
            withHotel: 600,
            costOfHouse: 50
        });

        propertyRent[12] = MonopolyLibrary.PropertyRent({
            propertyId: 12,
            site: 10,
            withOneHouse: 50,
            withTwoHouses: 150,
            withThreeHouses: 450,
            withFourHouses: 625,
            withHotel: 750,
            costOfHouse: 100
        });

        propertyRent[14] = MonopolyLibrary.PropertyRent({
            propertyId: 14,
            site: 10,
            withOneHouse: 50,
            withTwoHouses: 150,
            withThreeHouses: 450,
            withFourHouses: 625,
            withHotel: 750,
            costOfHouse: 100
        });

        propertyRent[15] = MonopolyLibrary.PropertyRent({
            propertyId: 15,
            site: 12,
            withOneHouse: 60,
            withTwoHouses: 180,
            withThreeHouses: 500,
            withFourHouses: 700,
            withHotel: 900,
            costOfHouse: 100
        });

        propertyRent[17] = MonopolyLibrary.PropertyRent({
            propertyId: 17,
            site: 14,
            withOneHouse: 70,
            withTwoHouses: 200,
            withThreeHouses: 550,
            withFourHouses: 750,
            withHotel: 950,
            costOfHouse: 100
        });

        propertyRent[19] = MonopolyLibrary.PropertyRent({
            propertyId: 19,
            site: 16,
            withOneHouse: 80,
            withTwoHouses: 220,
            withThreeHouses: 600,
            withFourHouses: 800,
            withHotel: 1000,
            costOfHouse: 100
        });

        propertyRent[20] = MonopolyLibrary.PropertyRent({
            propertyId: 20,
            site: 16,
            withOneHouse: 80,
            withTwoHouses: 220,
            withThreeHouses: 600,
            withFourHouses: 800,
            withHotel: 1000,
            costOfHouse: 100
        });

        propertyRent[22] = MonopolyLibrary.PropertyRent({
            propertyId: 22,
            site: 18,
            withOneHouse: 90,
            withTwoHouses: 250,
            withThreeHouses: 700,
            withFourHouses: 875,
            withHotel: 1050,
            costOfHouse: 150
        });

        propertyRent[24] = MonopolyLibrary.PropertyRent({
            propertyId: 24,
            site: 18,
            withOneHouse: 90,
            withTwoHouses: 250,
            withThreeHouses: 700,
            withFourHouses: 875,
            withHotel: 1050,
            costOfHouse: 150
        });

        propertyRent[25] = MonopolyLibrary.PropertyRent({
            propertyId: 25,
            site: 20,
            withOneHouse: 100,
            withTwoHouses: 300,
            withThreeHouses: 750,
            withFourHouses: 925,
            withHotel: 1100,
            costOfHouse: 150
        });

        propertyRent[27] = MonopolyLibrary.PropertyRent({
            propertyId: 27,
            site: 22,
            withOneHouse: 110,
            withTwoHouses: 330,
            withThreeHouses: 800,
            withFourHouses: 975,
            withHotel: 1150,
            costOfHouse: 150
        });

        propertyRent[28] = MonopolyLibrary.PropertyRent({
            propertyId: 28,
            site: 22,
            withOneHouse: 110,
            withTwoHouses: 330,
            withThreeHouses: 800,
            withFourHouses: 975,
            withHotel: 1150,
            costOfHouse: 150
        });

        propertyRent[30] = MonopolyLibrary.PropertyRent({
            propertyId: 30,
            site: 24,
            withOneHouse: 120,
            withTwoHouses: 360,
            withThreeHouses: 850,
            withFourHouses: 1025,
            withHotel: 1200,
            costOfHouse: 150
        });

        propertyRent[32] = MonopolyLibrary.PropertyRent({
            propertyId: 32,
            site: 26,
            withOneHouse: 130,
            withTwoHouses: 390,
            withThreeHouses: 900,
            withFourHouses: 1100,
            withHotel: 1275,
            costOfHouse: 200
        });

        propertyRent[33] = MonopolyLibrary.PropertyRent({
            propertyId: 33,
            site: 26,
            withOneHouse: 130,
            withTwoHouses: 390,
            withThreeHouses: 900,
            withFourHouses: 1100,
            withHotel: 1275,
            costOfHouse: 200
        });

        propertyRent[35] = MonopolyLibrary.PropertyRent({
            propertyId: 35,
            site: 28,
            withOneHouse: 150,
            withTwoHouses: 450,
            withThreeHouses: 1000,
            withFourHouses: 1200,
            withHotel: 1400,
            costOfHouse: 200
        });

        propertyRent[38] = MonopolyLibrary.PropertyRent({
            propertyId: 38,
            site: 35,
            withOneHouse: 175,
            withTwoHouses: 500,
            withThreeHouses: 1100,
            withFourHouses: 1300,
            withHotel: 1500,
            costOfHouse: 200
        });

        propertyRent[40] = MonopolyLibrary.PropertyRent({
            propertyId: 40,
            site: 50,
            withOneHouse: 200,
            withTwoHouses: 600,
            withThreeHouses: 1400,
            withFourHouses: 1700,
            withHotel: 2000,
            costOfHouse: 200
        });
    }

    // i changed your original getAllProperties function to this
    function getAllPropertiesM() external view returns (MonopolyLibrary.Property[] memory) {
        require(totalSupply > 0, "No properties minted yet");
        MonopolyLibrary.Property[] memory prop = new MonopolyLibrary.Property[](MAX_SUPPLY);
        for (uint8 i = 0; i < totalSupply; i++) {
            prop[i] = properties[i + 1];
        }
        return prop;
    }

    function returnProperty(uint8 propertyId) external view returns (MonopolyLibrary.Property memory property) {
        property = properties[propertyId];
        return property;
    }

    function returnTotalSupply() external view returns (uint8) {
        return totalSupply;
    }

    function returnPropertyRent(uint8 propertyId, uint8 upgradeStatus) public view returns (uint256 rent) {
        MonopolyLibrary.PropertyRent memory property = propertyRent[propertyId];
        MonopolyLibrary.Property memory propertyy = properties[propertyId];
        require(propertyy.propertyType == MonopolyLibrary.PropertyType.Property, "Not a Property");
        require(propertyId <= 40 && upgradeStatus <= 5, "invalid Property");
        uint256[6] memory rents = [
            property.site,
            property.withOneHouse,
            property.withTwoHouses,
            property.withThreeHouses,
            property.withFourHouses,
            property.withHotel
        ];

        require(upgradeStatus < rents.length, "Invalid upgrade status");
        rent = rents[upgradeStatus];
    }
}
