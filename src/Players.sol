//SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract PlayerS {
    constructor() {}

    function registerPlayer(address playerAddress, string memory username) external {}

    function joinGame(uint256 gameId) external {}

    function createGame() external {}

    function buyProperty(uint256 propertyId) external {}

    function rentProperty(uint256 propertyId) external {}

    function convertToLowerCase(string memory username) private pure returns (string memory) {
        bytes memory recievedUsernameBytes = bytes(username);
        bytes memory convertedUsernameBytes = new bytes(recievedUsernameBytes.length);

        for (uint256 i = 0; i < recievedUsernameBytes.length; i++) {
            if ((uint8(recievedUsernameBytes[i]) >= 65) && (uint8(recievedUsernameBytes[i]) <= 90)) {
                convertedUsernameBytes[i] = bytes1(uint8(recievedUsernameBytes[i]) + 32);
            } else {
                convertedUsernameBytes[i] = recievedUsernameBytes[i];
            }
            return string(convertedUsernameBytes);
        }
    }
}
