

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;


import { ERC20 } from "solmate/tokens/ERC20.sol";
// import { ERC20 } from "lib/solmate/src/tokens/ERC20.sol";

contract GameBank is ERC20("GameBank", "GB", 4) {

    uint256 constant private tolerace = 4;
    constructor(uint8 numberOfPlayers) {
        uint256 amountToMint = numberOfPlayers + tolerace; 
        _mint(address(this), amountToMint);
    }


}