//SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { ERC721 } from "lib/solmate/src/tokens/ERC721.sol";

contract NFT is ERC721("", "") {


    struct NFTP {
        uint8 id ;
        bytes description;
        bytes name ;
        uint256 amount ;
    }

    uint256 public id ;

    function tokenURI(uint256 id) public view override returns (string memory) {
        return "";
    }

    // function mintNFT() {
        
    // }

}
