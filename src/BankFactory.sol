// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;
import { GameBank } from "./Bank.sol";
contract BankFactory {
    address public gameToken;

    constructor(address _gameToken) {
        gameToken = _gameToken;
    }
    function deployGameBank(uint8 numberOfPlayer, address nftContractAddress) external returns( address) {
        GameBank gameBank = new GameBank(numberOfPlayer, nftContractAddress, this.gameToken());
        return address(gameBank);
    }

}