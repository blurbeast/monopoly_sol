// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.26;

import {GameBank} from "./Bank.sol";

contract BankFactory {
    address public gameToken;

    constructor(address _gameToken) {
        gameToken = _gameToken;
    }

    function deployGameBank(uint8 numberOfPlayer, address nftContractAddress) external returns (address) {
        return address(new GameBank(numberOfPlayer, nftContractAddress, this.gameToken()));
    }
}
