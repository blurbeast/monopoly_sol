//SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract PlayerS {
    mapping(address => bytes) public playerUsernames;
    mapping(bytes => bool) public usernameExists;
    mapping(address => bool) public alreadyRegistered;

    mapping(uint256 => Property) public properties;

    struct Property {
        string name;
        uint256 id;
        uint256 price;
        address owner;
        uint256 noOfTimesSold;
        bool isMortgaged;
    }

    event PropertySold(uint256 propertyId, address owner, uint256 price);
    event RentPaid(address tenant, address landlord, uint256 rentPrice, string property);
    event PropertyMortgaged(uint256 propertyId, uint256 mortgageAmount, address owner);

    event PropertyListedForSale(uint256 propertyId, uint256 propertyPrice, address owner);

    constructor() {}

    /**
     * @dev this function registers a new player to the game.
     *     @param playerAddress The address of the player.
     *     @param username The username of the player.
     *
     *     @notice this function checks if an address is already registered.
     *     @notice this function call on a helper function which converts the username to lowercase.
     *     @notice this function reads from the state to check if the converted lowercase username already exist to avoid duplicacy.
     *     @notice this function emits an event when a player is registered.
     */
    function registerPlayer(address playerAddress, string memory username) external {
        require(!alreadyRegistered[playerAddress], "player already registered");
        require(playerAddress.code.length == 0, "not an EOA" );

        bytes memory _usernameBytes = convertToLowerCase(username);

        require(!usernameExists[_usernameBytes], "username is already taken");

        alreadyRegistered[playerAddress] = true;
        usernameExists[_usernameBytes] = true;
        playerUsernames[playerAddress] = _usernameBytes;

        //emit an event
    }

    /**
     * @dev when this function is called, user should be able to join game via the provided gamesid if the game has been created but not ended yet.
     *     @dev this function should make a call to the game contract to check if provided gamesid is valid and not ended.
     *     @dev if the gamesid is valid and not ended, player should be added to the game.
     *     @dev this function emits an event when a player joins a game.
     *
     *     @param gameId The id of the game.
     */
    function joinGame(uint256 gameId) external {}

    /**
     * @dev player should be able to create a new game .
     *     @dev this function emits an event when a game is created.
     *
     *     @return the id of the created game.
     */
    function createGame() external returns (uint256) {}

    /**
     * @dev player should be able to buy a property.
     *     @dev this function emits an event when a player buys a property.
     *
     *     @param propertyId The id of the property.
     *     @dev player should only be able to buy a property if they have enough money.
     *     @dev player should only be able to buy a property when they land on the property
     *     @dev player should only be able to buy a property if they are not bankrupt.
     *     @dev player should only be able to buy a property if it should owned by the bank
     */
    function buyProperty(uint256 propertyId) external payable {
        Property storage property = properties[propertyId];

        require(msg.value == property.price, "Insufficient Ether to buy property");
        require(property.owner != msg.sender, "You already own the property");

        // If previously sold, transfer funds to the current owner
        if (property.noOfTimesSold > 0) {
            // require(property.owner != address(0), "Invalid current owner");
            (bool success,) = property.owner.call{value: property.price}("");
            require(success, "Transfer failed");
        }

        // Update ownership and increment sales count
        property.owner = msg.sender;
        property.noOfTimesSold++;

        // Emit an event for the purchase
        emit PropertySold(propertyId, msg.sender, property.price);
    }

    /**
     * @dev player should be able to sell a property.
     *  @dev this function emits an event when a player sells a property.
     *
     *  @param propertyId The id of the property.
     *  @dev player should only be able to sell a property if they own the property.
     */
    function sellProperty(uint256 propertyId) external {
        Property storage property = properties[propertyId];

        require(property.owner == msg.sender, "You are not the owner of this property");
        require(!property.isMortgaged, "Property is mortgaged and cannot be sold");

        emit PropertyListedForSale(propertyId, property.price, msg.sender);
    }

    /**
     * @dev player should be able to rent a property.
     *  @dev this function emits an event when a player rent a property.
     *
     *  @param propertyId The id of the property.
     *
     *  @dev property owner should recieve the money for the rent.
     *  @dev rent is 20% of the actual price of the property.
     */
    function rentProperty(uint256 propertyId) external {
        Property storage property = properties[propertyId];
        require(property.owner != address(0), "Invalid current owner");
        (bool success,) = property.owner.call{value: property.price}("");
        require(success, "Transfer failed");
        emit RentPaid(msg.sender, property.owner, property.price, property.name);
    }

    /**
     * @dev player should be able to upgrade a property.
     *     @dev this function emits an event when a player upgrades a property.
     *
     *     @param propertyId The id of the property.
     *     @dev player should only be able to upgrade a property if they own the property.
     *     @dev player should only be able to upgrade a property if they have enough money to do so.
     *     @dev upgrade cost should be 30% of the present price of the property.
     *     @dev upgrade level of a property should be incremented by 1.
     *     @dev upgrade level of a property should be limited to 5.
     */

    // Function to mortgage a property
    function mortgageProperty(uint256 propertyId) external {
        Property storage property = properties[propertyId];

        require(property.owner == msg.sender, "You are not the owner of this property");
        require(!property.isMortgaged, "Property is already mortgaged");

        property.isMortgaged = true;
        uint256 mortgageAmount = property.price / 2;
        // Transfer funds to the contract
        payable(address(this)).transfer(mortgageAmount);

        emit PropertyMortgaged(propertyId, mortgageAmount, msg.sender);
    }

    // Function to release a mortgage
    function releaseMortgage(uint256 propertyId) external payable {
        Property storage property = properties[propertyId];

        require(property.owner == msg.sender, "You are not the owner of this property");
        require(property.isMortgaged, "Property is not mortgaged");
        require(msg.value > 0, "Payment must be greater than zero");

        // Transfer the repaid funds to the contract owner or use it for future logic
        payable(address(this)).transfer(msg.value);

        // Release the mortgage
        property.isMortgaged = false;
    }

    function upgradeProperty(uint256 propertyId) external {}

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
