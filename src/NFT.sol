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
    }

    function createProperties() private {

    }

    function mint(address _minter) external {
        require(totalSupply  <= MAX_SUPPLY, "");
        uint256 tokenId = totalSupply + 1;
        _mint(_minter, tokenId);
        totalSupply++;
    }

    function createNftProperties() private {
        properties[1] = Property(
            bytes("Park Place"),
            100,
            bytes(""),
            1000
        );
        properties[2] = Property(
            bytes("Boardwalk"),
            100,
            bytes(""),
            1000
        );
        properties[3] = Property(
            bytes("Baltic Avenue"),
            100,
            bytes(""),
            1000
        );
        properties[4] = Property(
            bytes("Atlantic Avenue"),
            100,
            bytes(""),
            1000
        );
        properties[5] = Property(
            bytes("Marvin Gardens"),
            100,
            bytes(""),
            1000
        );
        properties[6] = Property(
            bytes("Pacific Avenue"),
            100,
            bytes(""),
            1000
        );
        properties[7] = Property(
            bytes("North Carolina Avenue"),
            100,
            bytes(""),
            1000
        );
        properties[8] = Property(
            bytes("Pennsylvania Avenue"),
            100,
            bytes(""),
            1000
        );
        properties[9] = Property(
            bytes("Short Line"),
            100,
            bytes(""),
            1000
        );
        properties[10] = Property(
            bytes("Reading Railroad"),
            100,
            bytes(""),
            1000
        );
        properties[11] = Property(
            bytes("B&O Railroad"),
            100,
            bytes(""),
            1000
        );
        properties[12] = Property(
            bytes("Pennsylvania Railroad"),
            100,
            bytes(""),
            1000
        );
        properties[13] = Property(
            bytes("Electric Company"),
            100,
            bytes(""),
            1000
        );
        properties[14] = Property(
            bytes("Water Works"),
            100,
            bytes(""),
            1000
        );
        properties[15] = Property(
            bytes("Connecticut Avenue"),
            100,
            bytes(""),
            1000
        );
        properties[16] = Property(
            bytes("Vermont Avenue"),
            100,
            bytes(""),
            1000
        );
        properties[17] = Property(
            bytes("Oriental Avenue"),
            100,
            bytes(""),
            1000
        );
        properties[18] = Property(
            bytes("St. Charles Place"),
            100,
            bytes(""),
            1000
        );
        properties[19] = Property(
            bytes("States Avenue"),
            100,
            bytes(""),
            1000
        );
        properties[20] = Property(
            bytes("Virginia Avenue"),
            100,
            bytes(""),
            1000
        );
        properties[21] = Property(
            bytes("St. James Place"),
            100,
            bytes(""),
            1000
        );
        properties[22] = Property(
            bytes("Tennessee Avenue"),
            100,
            bytes(""),
            1000
        );
        properties[23] = Property(
            bytes("New York Avenue"),
            100,
            bytes(""),
            1000
        );
        properties[24] = Property(
            bytes("Kentucky Avenue"),
            100,
            bytes(""),
            1000
        );
        properties[25] = Property(
            bytes("Indiana Avenue"),
            100,
            bytes(""),
            1000
        );
        properties[26] = Property(
            bytes("Illinois Avenue"),
            100,
            bytes(""),
            1000
        );
        properties[27] = Property(
            bytes("Atlantic Avenue"),
            100,
            bytes(""),
            1000
        );
        
    }

    function distributeToken() external view returns (string[] memory) {
        string[] memory tokenIds = new string[](MAX_SUPPLY);
        for (uint8 i = 0; i < MAX_SUPPLY; i++) {
            tokenIds[i] = tokenURI(i + uint8(1));
        }

        return tokenIds;
    }
}
