//SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "lib/openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract CollectionNFT is ERC721URIStorage {
    string private decription;
    string private baseUri;
    mapping(address => uint256) private minterTokenId;

    constructor(string memory name, string memory symbol, string memory desc, string memory uri)
    ERC721(name, symbol)
    {
        decription = desc;
        baseUri = uri;
    }

    function mint(address _minter) external {
        uint256 _tokenId = minterTokenId[_minter];
        _mint(_minter, ++_tokenId);
    }
}