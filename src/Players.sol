//SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract PlayerS {

    mapping (address => bytes) public playerUsernames;
    mapping (bytes => bool ) public usernameExists;
    mapping (address => bool ) public alreadyRegistered;
    constructor() {}

    function registerPlayer(address playerAddress, string memory username) external {
        require(!alreadyRegistered[playerAddress], "player already registered");

        bytes memory _usernameBytes = convertToLowerCase(username);

        require(!usernameExists[_usernameBytes], "username is already taken");

        


    }

    function joinGame(uint256 gameId) external {}

    function createGame() external {}

    function buyProperty(uint256 propertyId) external {}

    function rentProperty(uint256 propertyId) external {}

    function convertToLowerCase(string memory username) private pure returns (bytes memory) {
        bytes memory recievedUsernameBytes = bytes(username);
        bytes memory convertedUsernameBytes = new bytes(recievedUsernameBytes.length);

        for (uint256 i = 0; i < recievedUsernameBytes.length; i++) {
            if ((uint8(recievedUsernameBytes[i]) >= 65) && (uint8(recievedUsernameBytes[i]) <= 90)) {
                convertedUsernameBytes[i] = bytes1(uint8(recievedUsernameBytes[i]) + 32);
            } else {
                convertedUsernameBytes[i] = recievedUsernameBytes[i];
            }
            return convertedUsernameBytes;
            // return string(convertedUsernameBytes);
        }
    }
}
