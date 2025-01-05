//SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract PlayerS {
    mapping(address => bytes) public playerUsernames;
    mapping(bytes => bool) public usernameExists;
    mapping(address => bool) public alreadyRegistered;

    constructor() {}


    /**
        @dev this function registers a new player to the game.
        @param playerAddress The address of the player.
        @param username The username of the player.

        @notice this function checks if an address is already registered.
        @notice this function call on a helper function which converts the username to lowercase.
        @notice this function reads from the state to check if the converted lowercase username already exist to avoid duplicacy.
        @notice this function emits an event when a player is registered.
     */
    function registerPlayer(address playerAddress, string memory username) external {
        
        require(!alreadyRegistered[playerAddress], "player already registered");

        bytes memory _usernameBytes = convertToLowerCase(username);

        require(!usernameExists[_usernameBytes], "username is already taken");

        alreadyRegistered[playerAddress] = true;
        usernameExists[_usernameBytes] = true;
        playerUsernames[playerAddress] = _usernameBytes;

        //emit an event 
    }


    /**
        @dev when this function is called, user should be able to join game via the provided gamesid if the game has been created but not ended yet.
        @dev this function should make a call to the game contract to check if provided gamesid is valid and not ended.
        @dev if the gamesid is valid and not ended, player should be added to the game.
        @dev this function emits an event when a player joins a game.

        @param gameId The id of the game.
     */
    function joinGame(uint256 gameId) external {}

    /**
        @dev player should be able to create a new game .
        @dev this function emits an event when a game is created.

        @return the id of the created game.
     */
    function createGame() external view returns (uint256 ){}

    
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
        }
        return convertedUsernameBytes;
    }
}
