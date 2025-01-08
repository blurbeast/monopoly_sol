//SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "lib/openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

/**
 *     @dev this is the generalized version of NFT contract.
 *     @notice this is a generalized version of NFT contract that can be used for any ERC721 token.
 *     @dev this contract has the total supply of 30 NFT to be used across all the games played on this platform.
 *     @dev Each NFT has a unique tokenId, and the tokenId is mapped to the owner's address.
 *     @dev The mint function is used to create new NFTs which is not more than 30 .
 *     @dev this contract is called upon on every new game created and it NFT URI is sent to the bank contract which then creates a property for each of the NFTs.
 *     @dev the URI of each NFT is fetched from the bank contract using the tokenId.
 */
contract GeneralNFT is ERC721URIStorage {
    uint8 public constant MAX_SUPPLY = 30;
    uint8 public totalSupply;
    string private baseUri;

    struct Property {
        bytes name;
        uint256 rentAmount;
        bytes uri;
        uint256 buyAmount;
    }

    Property[] private properties;

    constructor(string memory uri) ERC721("MonoPoly", "MNP") {
        baseUri = uri;
        createNftProperties();
    }

    function mint(address _minter) external {
        require(totalSupply <= MAX_SUPPLY, "");
        uint256 tokenId = totalSupply + 1;
        _mint(_minter, tokenId);
        totalSupply++;
    }

    // okay but like this when getproperties() function , the uri should follow as well .
    function createNftProperties() private {
    // Brown (Dark Purple) Properties
    properties[2] = Property(bytes("Mediterranean Avenue"), 2, bytes(""), 60);
    properties[4] = Property(bytes("Baltic Avenue"), 4, bytes(""), 60);

    // Light Blue Properties
    properties[7] = Property(bytes("Connecticut Avenue"), 8, bytes(""), 120);
    properties[9] = Property(bytes("Vermont Avenue"), 6, bytes(""), 100);
    properties[10] = Property(bytes("Oriental Avenue"), 6, bytes(""), 100);

    // Pink (Magenta) Properties
    properties[12] = Property(bytes("St. Charles Place"), 10, bytes(""), 140);
    properties[14] = Property(bytes("States Avenue"), 10, bytes(""), 140);
    properties[15] = Property(bytes("Virginia Avenue"), 12, bytes(""), 160);

    // Orange Properties
    properties[17] = Property(bytes("St. James Place"), 14, bytes(""), 180);
    properties[19] = Property(bytes("Tennessee Avenue"), 14, bytes(""), 180);
    properties[20] = Property(bytes("New York Avenue"), 16, bytes(""), 200);

    // Red Properties
    properties[22] = Property(bytes("Kentucky Avenue"), 18, bytes(""), 220);
    properties[24] = Property(bytes("Indiana Avenue"), 18, bytes(""), 220);
    properties[25] = Property(bytes("Illinois Avenue"), 20, bytes(""), 240);

    // Yellow Properties
    properties[27] = Property(bytes("Atlantic Avenue"), 22, bytes(""), 260);
    properties[28] = Property(bytes("Ventnor Avenue"), 22, bytes(""), 260);
    properties[30] = Property(bytes("Marvin Gardens"), 24, bytes(""), 280);

    // Green Properties
    properties[32] = Property(bytes("Pacific Avenue"), 26, bytes(""), 300);
    properties[33] = Property(bytes("North Carolina Avenue"), 26, bytes(""), 300);
    properties[35] = Property(bytes("Pennsylvania Avenue"), 28, bytes(""), 320);

    // Dark Blue Properties
    properties[38] = Property(bytes("Park Place"), 35, bytes(""), 350);
    properties[40] = Property(bytes("Boardwalk"), 50, bytes(""), 400);

    // Railroads
    properties[6] = Property(bytes("Reading Railroad"), 25, bytes(""), 200);
    properties[16] = Property(bytes("Pennsylvania Railroad"), 25, bytes(""), 200);
    properties[26] = Property(bytes("B&O Railroad"), 25, bytes(""), 200);
    properties[36] = Property(bytes("Short Line"), 25, bytes(""), 200);

    // Utilities
    properties[13] = Property(bytes("Electric Company"), 0, bytes(""), 150);
    properties[29] = Property(bytes("Water Works"), 0, bytes(""), 150);

    // Special Spaces (Non-properties but important for game logic)
    properties[1] = Property(bytes("GO"), 0, bytes(""), 0);
    properties[3] = Property(bytes("Community Chest 1"), 0, bytes(""), 0);
    properties[5] = Property(bytes("Income Tax"), 0, bytes(""), 0);
    properties[8] = Property(bytes("Chance 1"), 0, bytes(""), 0);
    properties[11] = Property(bytes("Jail"), 0, bytes(""), 0);
    properties[18] = Property(bytes("Community Chest 2"), 0, bytes(""), 0);
    properties[21] = Property(bytes("Free Parking"), 0, bytes(""), 0);
    properties[23] = Property(bytes("Chance 2"), 0, bytes(""), 0);
    properties[31] = Property(bytes("Go To Jail"), 0, bytes(""), 0);
    properties[34] = Property(bytes("Community Chest 3"), 0, bytes(""), 0);
    properties[37] = Property(bytes("Chance 3"), 0, bytes(""), 0);
    properties[39] = Property(bytes("Luxury Tax"), 0, bytes(""), 0);
}

    function populatePropertyUri() private {
        require(totalSupply > 0, "not property minted yet");
        for (uint8 i = 1; i <= totalSupply; i++) {
            string memory onChainUri = tokenURI(i);
            Property storage property = properties[i];
            property.uri = bytes(onChainUri);
        }
    }

    function distributeToken() external view returns (string[] memory) {
        string[] memory tokenIds = new string[](MAX_SUPPLY);
        for (uint8 i = 0; i < MAX_SUPPLY; i++) {
            tokenIds[i] = tokenURI(i + uint8(1));
        }

        return tokenIds;
    }
}
