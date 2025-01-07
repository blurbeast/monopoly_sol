//SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract Dice {
    function rollDice() external view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender, blockhash(block.number - 1)))) % 6 + 1;
    }
}
