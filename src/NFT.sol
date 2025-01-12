//SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "lib/openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

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

    // Property[] private properties = new Property[](MAX_SUPPLY);
    mapping(uint8 => Property) private properties;

    constructor(string memory uri) ERC721("MonoPoly", "MNP") {
        baseUri = uri;
        createNftProperties();
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

    // okay but like this when getproperties() function , the uri should follow as well .
    function createNftProperties() private {
        properties[1] = Property({
            name: "GO",
            rentAmount: 0,
            uri: "",
            buyAmount: 0,
            propertyType: PropertyType.Special,
            color: PropertyColors.PURPLE
        });

        // Brown Properties
        properties[2] = Property({
            name: "Mediterranean Avenue",
            rentAmount: 2,
            uri: "",
            buyAmount: 60,
            propertyType: PropertyType.Property,
            color: PropertyColors.BROWN
        });

        properties[3] = Property({
            name: "Community Chest 1",
            rentAmount: 0,
            uri: "",
            buyAmount: 0,
            propertyType: PropertyType.Special,
            color: PropertyColors.PURPLE
        });

        properties[4] = Property({
            name: "Baltic Avenue",
            rentAmount: 4,
            uri: "",
            buyAmount: 60,
            propertyType: PropertyType.Property,
            color: PropertyColors.BROWN
        });

        properties[5] = Property({
            name: "Income Tax",
            rentAmount: 0,
            uri: "",
            buyAmount: 0,
            propertyType: PropertyType.Special,
            color: PropertyColors.PURPLE
        });

        properties[6] = Property({
            name: "Reading Railroad",
            rentAmount: 25,
            uri: "",
            buyAmount: 200,
            propertyType: PropertyType.RailStation,
            color: PropertyColors.PURPLE
        });

        // Light Blue Properties
        properties[7] = Property({
            name: "Connecticut Avenue",
            rentAmount: 8,
            uri: "",
            buyAmount: 120,
            propertyType: PropertyType.Property,
            color: PropertyColors.BLUE
        });

        properties[8] = Property({
            name: "Chance 1",
            rentAmount: 0,
            uri: "",
            buyAmount: 0,
            propertyType: PropertyType.Special,
            color: PropertyColors.PURPLE
        });

        properties[9] = Property({
            name: "Vermont Avenue",
            rentAmount: 6,
            uri: "",
            buyAmount: 100,
            propertyType: PropertyType.Property,
            color: PropertyColors.BLUE
        });

        properties[10] = Property({
            name: "Oriental Avenue",
            rentAmount: 6,
            uri: "",
            buyAmount: 100,
            propertyType: PropertyType.Property,
            color: PropertyColors.BLUE
        });

        properties[11] = Property({
            name: "Jail",
            rentAmount: 0,
            uri: "",
            buyAmount: 0,
            propertyType: PropertyType.Special,
            color: PropertyColors.PURPLE
        });

        // Pink Properties
        properties[12] = Property({
            name: "St. Charles Place",
            rentAmount: 10,
            uri: "",
            buyAmount: 140,
            propertyType: PropertyType.Property,
            color: PropertyColors.PINK
        });

        properties[13] = Property({
            name: "Electric Company",
            rentAmount: 0,
            uri: "",
            buyAmount: 150,
            propertyType: PropertyType.Utility,
            color: PropertyColors.PURPLE
        });

        properties[14] = Property({
            name: "States Avenue",
            rentAmount: 10,
            uri: "",
            buyAmount: 140,
            propertyType: PropertyType.Property,
            color: PropertyColors.PINK
        });

        properties[15] = Property({
            name: "Virginia Avenue",
            rentAmount: 12,
            uri: "",
            buyAmount: 160,
            propertyType: PropertyType.Property,
            color: PropertyColors.PINK
        });

        properties[16] = Property({
            name: "Pennsylvania Railroad",
            rentAmount: 25,
            uri: "",
            buyAmount: 200,
            propertyType: PropertyType.RailStation,
            color: PropertyColors.PURPLE
        });

        // Orange Properties
        properties[17] = Property({
            name: "St. James Place",
            rentAmount: 14,
            uri: "",
            buyAmount: 180,
            propertyType: PropertyType.Property,
            color: PropertyColors.ORANGE
        });

        properties[18] = Property({
            name: "Community Chest 2",
            rentAmount: 0,
            uri: "",
            buyAmount: 0,
            propertyType: PropertyType.Special,
            color: PropertyColors.PURPLE
        });

        properties[19] = Property({
            name: "Tennessee Avenue",
            rentAmount: 14,
            uri: "",
            buyAmount: 180,
            propertyType: PropertyType.Property,
            color: PropertyColors.ORANGE
        });

        properties[20] = Property({
            name: "New York Avenue",
            rentAmount: 16,
            uri: "",
            buyAmount: 200,
            propertyType: PropertyType.Property,
            color: PropertyColors.ORANGE
        });

        properties[21] = Property({
            name: "Free Parking",
            rentAmount: 0,
            uri: "",
            buyAmount: 0,
            propertyType: PropertyType.Special,
            color: PropertyColors.PURPLE
        });

        // Red Properties
        properties[22] = Property({
            name: "Kentucky Avenue",
            rentAmount: 18,
            uri: "",
            buyAmount: 220,
            propertyType: PropertyType.Property,
            color: PropertyColors.RED
        });

        properties[23] = Property({
            name: "Chance 2",
            rentAmount: 0,
            uri: "",
            buyAmount: 0,
            propertyType: PropertyType.Special,
            color: PropertyColors.PURPLE
        });

        properties[24] = Property({
            name: "Indiana Avenue",
            rentAmount: 18,
            uri: "",
            buyAmount: 220,
            propertyType: PropertyType.Property,
            color: PropertyColors.RED
        });

        properties[25] = Property({
            name: "Illinois Avenue",
            rentAmount: 20,
            uri: "",
            buyAmount: 240,
            propertyType: PropertyType.Property,
            color: PropertyColors.RED
        });

        properties[26] = Property({
            name: "B&O Railroad",
            rentAmount: 25,
            uri: "",
            buyAmount: 200,
            propertyType: PropertyType.RailStation,
            color: PropertyColors.PURPLE
        });

        // Yellow Properties
        properties[27] = Property({
            name: "Atlantic Avenue",
            rentAmount: 22,
            uri: "",
            buyAmount: 260,
            propertyType: PropertyType.Property,
            color: PropertyColors.YELLOW
        });

        properties[28] = Property({
            name: "Ventnor Avenue",
            rentAmount: 22,
            uri: "",
            buyAmount: 260,
            propertyType: PropertyType.Property,
            color: PropertyColors.YELLOW
        });

        properties[29] = Property({
            name: "Water Works",
            rentAmount: 0,
            uri: "",
            buyAmount: 150,
            propertyType: PropertyType.Utility,
            color: PropertyColors.PURPLE
        });

        properties[30] = Property({
            name: "Marvin Gardens",
            rentAmount: 24,
            uri: "",
            buyAmount: 280,
            propertyType: PropertyType.Property,
            color: PropertyColors.YELLOW
        });

        properties[31] = Property({
            name: "Go To Jail",
            rentAmount: 0,
            uri: "",
            buyAmount: 0,
            propertyType: PropertyType.Special,
            color: PropertyColors.PURPLE
        });

        // Green Properties
        properties[32] = Property({
            name: "Pacific Avenue",
            rentAmount: 26,
            uri: "",
            buyAmount: 300,
            propertyType: PropertyType.Property,
            color: PropertyColors.GREEN
        });

        properties[33] = Property({
            name: "North Carolina Avenue",
            rentAmount: 26,
            uri: "",
            buyAmount: 300,
            propertyType: PropertyType.Property,
            color: PropertyColors.GREEN
        });

        properties[34] = Property({
            name: "Community Chest 3",
            rentAmount: 0,
            uri: "",
            buyAmount: 0,
            propertyType: PropertyType.Special,
            color: PropertyColors.PURPLE
        });

        properties[35] = Property({
            name: "Pennsylvania Avenue",
            rentAmount: 28,
            uri: "",
            buyAmount: 320,
            propertyType: PropertyType.Property,
            color: PropertyColors.GREEN
        });

        properties[36] = Property({
            name: "Short Line",
            rentAmount: 25,
            uri: "",
            buyAmount: 200,
            propertyType: PropertyType.RailStation,
            color: PropertyColors.PURPLE
        });

        properties[37] = Property({
            name: "Chance 3",
            rentAmount: 0,
            uri: "",
            buyAmount: 0,
            propertyType: PropertyType.Special,
            color: PropertyColors.PURPLE
        });

        // Dark Blue Properties
        properties[38] = Property({
            name: "Park Place",
            rentAmount: 35,
            uri: "",
            buyAmount: 350,
            propertyType: PropertyType.Property,
            color: PropertyColors.BLUE
        });

        properties[39] = Property({
            name: "Luxury Tax",
            rentAmount: 0,
            uri: "",
            buyAmount: 0,
            propertyType: PropertyType.Special,
            color: PropertyColors.PURPLE
        });

        properties[40] = Property({
            name: "Boardwalk",
            rentAmount: 50,
            uri: "",
            buyAmount: 400,
            propertyType: PropertyType.Property,
            color: PropertyColors.BLUE
        });
    }

    function populatePropertyUri() private {
        require(totalSupply > 0, "no property minted yet");
        for (uint8 i = 1; i <= totalSupply; i++) {
            string memory onChainUri = tokenURI(i);
            Property storage property = properties[i];
            property.uri = bytes(onChainUri);
        }
    }

    function getAllProperties() external view returns (Property[] memory) {
        require(totalSupply > 0, "No properties minted yet");
        Property[] memory prop = new Property[](MAX_SUPPLY);
        for (uint8 i = 0; i < totalSupply; i++) {
            prop[i] = properties[i + 1];
        }
        return prop;
    }
}
