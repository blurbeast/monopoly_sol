// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;
import { GameBank } from "./Bank.sol";
contract BankFactory {
    function deployGameBank(uint8 numberOfPlayer, address nftContractAddress) external returns( address) {
        GameBank gameBank = new GameBank(numberOfPlayer, nftContractAddress);
        return address(gameBank);
    }
}