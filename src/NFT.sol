//SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "lib/openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721URIStorage.sol";



/**
    @dev this is the generalized version of NFT contract.
    @notice this is a generalized version of NFT contract that can be used for any ERC721 token.

    @dev this contract has the total supply of 30 NFT to be used across all the games played on this platform.
    @dev Each NFT has a unique tokenId, and the tokenId is mapped to the owner's address.
    @dev The mint function is used to create new NFTs which is not more than 30 .
    @dev this contract is called upon on every new game created and it NFT URI is sent to the bank contract which then creates a property for each of the NFTs.
    @dev the URI of each NFT is fetched from the bank contract using the tokenId.
 */

contract GeneralNFT is ERC721URIStorage {
    uint8 public constant MAX_SUPPLY = 30;
    uint8 public totalSupply;

    string private decription;
    string private baseUri;
    mapping(address => uint256) private minterTokenId;

    constructor(string memory name, string memory symbol, string memory desc, string memory uri) ERC721(name, symbol) {
        decription = desc;
        baseUri = uri;
    }

    function mint(address _minter) external {
        require(totalSupply < MAX_SUPPLY, "");
        uint256 tokenId = totalSupply + 1;
        totalSupply++;
        _mint(_minter, tokenId);
    }

    function distributeToken() external view returns (string[] memory) {

        string[] memory tokenIds = new string[](MAX_SUPPLY);
        for (uint8 i = 0; i < MAX_SUPPLY; i++) {
            tokenIds[i] = tokenURI(i + uint8(1));
        }


        return tokenIds;
    }
}
