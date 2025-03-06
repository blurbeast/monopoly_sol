//SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract Dice {
    function rollDice() external view returns (uint8, uint8) {
        return (_firstDice(), _secondDice());
    }

    function _firstDice() private view returns (uint8) {
        // return uint8((block.timestamp % 6) + 1);

        return 4; // for test purpose
    }

    function _secondDice() private view returns (uint8) {
        // return uint8(((block.timestamp / 7) % 6) + 1);
        return 2; // for test purpose
    }
}
