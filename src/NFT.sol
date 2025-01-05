//SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "lib/openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

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
}
