
//pragma solidity ^0.8.26;
//
//import {ERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
//import {ReentrancyGuard} from "lib/openzeppelin-contracts/contracts/utils/ReentrancyGuard.sol";
//
//import "./libraries/MonopolyLibrary.sol";
//// import {console} from "forge-std/Test.sol";
//
//event RentPaid(address tenant, address landlord, uint256 rentPrice, bytes property);
//
//event PropertyMortgaged(uint256 propertyId, uint256 mortgageAmount, address owner);
//
//event PropertyListedForSale(uint256 propertyId, uint256 propertyPrice, address owner);
//
//event PropertyUpGraded(uint256 propertyId);
//
//event PropertyDownGraded(uint256 propertyId);

//interface NFTContract {
//    function getAllProperties() external view returns (MonopolyLibrary.Property[] memory);
//}

/**
// * @title GameBank
// * @dev A simple ERC20 token representing a game bank.
// * @dev this is intended to be deployed upon every new creation of a new game.
// */
//contract GameBank is ERC20("GameBank", "GB"), ReentrancyGuard {
//
////    event RentPaid(address tenant, address landlord, uint256 rentPrice, bytes property);
////
////    event PropertyMortgaged(uint256 propertyId, uint256 mortgageAmount, address owner);
////
////    event PropertyListedForSale(uint256 propertyId, uint256 propertyPrice, address owner);
////
////    event PropertyUpGraded(uint256 propertyId);
////
////    event PropertyDownGraded(uint256 propertyId);
//
//    using MonopolyLibrary for MonopolyLibrary.PropertyG;
//    using MonopolyLibrary for MonopolyLibrary.Property;
//    using MonopolyLibrary for MonopolyLibrary.PropertyColors;
//    using MonopolyLibrary for MonopolyLibrary.PropertyType;
//    using MonopolyLibrary for MonopolyLibrary.BenefitType;
//    using MonopolyLibrary for MonopolyLibrary.Benefit;
//    using MonopolyLibrary for MonopolyLibrary.Proposal;
//
//    MonopolyLibrary.PropertyG[] private properties;
//
//    //    mapping(uint8 => MonopolyLibrary.Bid) public bids;
//    mapping(uint8 => address) public propertyOwner;
//    mapping(uint256 => bool) private mortgagedProperties;
//    mapping(uint8 => uint8) private noOfUpgrades;
//
//    uint16 private constant decimalPlace = 1000;
//    //
//    mapping(MonopolyLibrary.PropertyColors => mapping(address => uint8)) public noOfColorGroupOwnedByUser;
//    mapping(MonopolyLibrary.PropertyColors => uint8) private upgradeUserPropertyColorOwnedNumber;
//
//    event PropertyBid(uint8 indexed propertyId, address indexed bidder, uint256 bidAmount);
//    event PropertySold(uint8 indexed propertyId, address indexed newOwner, uint256 amount);
//
//    // the tolerance is the extra token minted to cater for player borrowing and community card picked .
//    uint256 private constant tolerance = 4;
//    NFTContract private nftContract;
//    uint8 private propertySize;
//    mapping(uint8 => MonopolyLibrary.PropertyG) public gameProperties;
//    mapping(address => MonopolyLibrary.PropertySwap) public propertySwap;
//
//    /**
//     * @dev Initializes the contract with a fixed supply of tokens.
//     * @param numberOfPlayers the total number of players.
//     * @dev _mint an internal function that mints the total token needed for the game.
//     */
//    constructor(uint8 numberOfPlayers, address _nftContract) {
//        uint256 amountToMint = (numberOfPlayers + tolerance) * decimalPlace;
//
//        require(_nftContract.code.length > 0, "not a contract address");
//        nftContract = NFTContract(_nftContract);
//        _mint(address(this), amountToMint);
//        _gameProperties();
//        _setNumberForColoredPropertyNumber();
//    }
//
//    function getNumberOfUserOwnedPropertyOnAColor(address user, MonopolyLibrary.PropertyColors color)
//        external
//        view
//        returns (uint8)
//    {
//        return noOfColorGroupOwnedByUser[color][user];
//    }
//
//    function mint(address to, uint256 amount) external {
//        _transfer(address(this), to, amount);
//    }
//
//    function mints(address[] memory to, uint256 amount) external  {
//        for(uint8 i = 0; i < to.length; i++) {
//            _transfer(address(this), to[i], amount);
//        }
//    }
//
//    //helper function
//    function _gameProperties() private {
//        MonopolyLibrary.Property[] memory allProperties = nftContract.getAllProperties();
//        uint256 size = allProperties.length;
//        propertySize = uint8(allProperties.length);
//        for (uint8 i = 0; i < size; i++) {
//            MonopolyLibrary.Property memory property = allProperties[i];
//            _distributePropertyType(property, i);
//        }
//    }
//    //helper function
//
//    function _setNumberForColoredPropertyNumber() private {
//        upgradeUserPropertyColorOwnedNumber[MonopolyLibrary.PropertyColors.PINK] = 3;
//        upgradeUserPropertyColorOwnedNumber[MonopolyLibrary.PropertyColors.YELLOW] = 3;
//        upgradeUserPropertyColorOwnedNumber[MonopolyLibrary.PropertyColors.BLUE] = 3;
//        upgradeUserPropertyColorOwnedNumber[MonopolyLibrary.PropertyColors.ORANGE] = 3;
//        upgradeUserPropertyColorOwnedNumber[MonopolyLibrary.PropertyColors.RED] = 3;
//        upgradeUserPropertyColorOwnedNumber[MonopolyLibrary.PropertyColors.GREEN] = 3;
//        upgradeUserPropertyColorOwnedNumber[MonopolyLibrary.PropertyColors.PURPLE] = 3;
//        upgradeUserPropertyColorOwnedNumber[MonopolyLibrary.PropertyColors.BROWN] = 2;
//    }
//
//    //helper function
//    function _distributePropertyType(MonopolyLibrary.Property memory prop, uint8 position) private {
//        gameProperties[position + 1] = MonopolyLibrary.PropertyG(
//            prop.name, prop.uri, prop.buyAmount, prop.rentAmount, address(this), 0, prop.propertyType, prop.color
//        );
//    }
//
//    // the front end should check if the property is owned by the bank or another player ,
//    // if owned by the bank , a buy property button should be activated
//    // if owned by another player , a rent button or make proposal or bid deal should be activated...
//
//    // this function is only meant to interact with the bank .
//
//    /**
//     * @dev enables players to purchase properties from the bank
//     * @param propertyId The id of the property on the monopoly board
//     * @param buyer Address of the player that is making the purchase
//     */
//    function buyProperty(uint8 propertyId, address buyer) external nonReentrant {
//        MonopolyLibrary.PropertyG storage property = gameProperties[propertyId];
//        require(property.propertyType != MonopolyLibrary.PropertyType.Special, "Invalid property, could not be bought");
//        require(property.owner != buyer, "You already own the property");
//        // require(property.buyAmount > 0, "Property price must be greater than zero");
//
//        // when dealing with bank and property, the bank will only take what is said to be the actual amount
//        // require(bidAmount >= property.buyAmount, "Bid amount must be at least the property price");
//
//        require(balanceOf(buyer) >= property.buyAmount, "insufficient balance");
//
//        // commented this out because even though a player mortagage property, he/she still retains the ownership
//        // require(!mortgagedProperties[propertyId], "Property is Mortgaged and cannot be bought");
//        require(property.owner == address(this), "already owned by a player");
//
//        // // Approve contract to spend bid amount (requires user to call `approve` beforehand)
//        // require(balanceOf(msg.sender) >= bidAmount, "Insufficient funds for bid");
//
//        _transfer(buyer, address(this), property.buyAmount);
//
//        // Update ownership and increment sales count
//        property.owner = buyer;
//        propertyOwner[propertyId] = buyer;
//
//        //no need to reassign again as the previous read was from the state and it was said to be storage .
//        // gameProperties[propertyId] = property;
//
//        noOfColorGroupOwnedByUser[property.propertyColor][buyer] += 1;
//
//        property.propertyType == MonopolyLibrary.PropertyType.RailStation ? numberOfOwnedRailways[buyer] += 1 : 0;
//
//        // // Emit an event
//    }
//
//    mapping(uint256 => MonopolyLibrary.Proposal) public inGameProposals;
//    mapping(uint8 => uint8) public propertyToProposal;
//    uint256 private proposalIds;
//    mapping(uint256 => MonopolyLibrary.SwappedType) public swappedType;
//
//    function getProposalSwappedType(uint8 proposalId) external view returns (MonopolyLibrary.SwappedType memory) {
//        return swappedType[proposalId];
//    }
//
//    // correct i think
//    /**
//     * @dev allows players to propose a trade with other players
//     * @param proposer Address of player that initiate the transcation
//     * @param otherPlayer Address of the player the user want to propose a trade with
//     * @param proposedPropertyId optional id of the property the user wants to buy
//     * @param biddingPropertyId optional id of the users property he wants to put in  the transcation
//     * @param swapType An enum suggesting the type of swap operation the user intends to carry out
//     * @param amountInvolved the amount of the trade to be carried out
//     */
//    function makeProposal(
//        address proposer,
//        address otherPlayer,
//        uint8 proposedPropertyId,
//        uint8 biddingPropertyId,
//        MonopolyLibrary.SwapType swapType,
//        uint256 amountInvolved
//    ) external {
//        // using tdd
//        address realOwner = propertyOwner[proposedPropertyId];
//        require(realOwner == proposer, "asset specified is not owned by player");
//        require(!mortgagedProperties[proposedPropertyId], "asset on mortgage");
//        if (biddingPropertyId > 0) {
//            require(
//                !mortgagedProperties[biddingPropertyId],
//                "bidding property is on mortgage , hence proposal cannot be made"
//            );
//        }
//
//        proposalIds += 1;
//        MonopolyLibrary.Proposal storage proposal = inGameProposals[proposalIds];
//        proposal.swapType = swapType;
//        proposal.otherPlayer = otherPlayer;
//        proposal.player = proposer;
//
//        proposal.swapType == MonopolyLibrary.SwapType.PROPERTY_FOR_PROPERTY
//            ? _propertyForProperty(proposalIds, proposedPropertyId, biddingPropertyId)
//            : proposal.swapType == MonopolyLibrary.SwapType.PROPERTY_FOR_CASH_AND_PROPERTY
//                ? _propertyForCashAndProperty(proposalIds, proposedPropertyId, biddingPropertyId, amountInvolved)
//                : proposal.swapType == MonopolyLibrary.SwapType.PROPERTY_AND_CASH_FOR_PROPERTY
//                    ? _propertyAndCashForProperty(proposalIds, proposedPropertyId, amountInvolved, biddingPropertyId)
//                    : proposal.swapType == MonopolyLibrary.SwapType.PROPERTY_FOR_CASH
//                        ? _propertyForCash(proposalIds, proposedPropertyId, amountInvolved)
//                        : _cashForProperty(proposalIds, amountInvolved, biddingPropertyId);
//
//        isProposalActive[proposalIds] = true;
//
//        // to emit an event here
//    }
//
//    /**
//     * @dev function that executes the cash for property swap type
//     * @param proposalId Id of the users proposal to be acted upon
//     * @param proposedAmount Amount the user is proposing
//     * @param biddingPropertyId the id of the property the user wants to trade
//     */
//    function _cashForProperty(uint256 proposalId, uint256 proposedAmount, uint8 biddingPropertyId) private {
//        MonopolyLibrary.SwappedType storage swappedSwapType = swappedType[proposalId];
//        swappedSwapType.cashForProperty.proposedAmount = proposedAmount;
//        swappedSwapType.cashForProperty.biddingPropertyId = biddingPropertyId;
//    }
//
//    /**
//     * @dev function that executes the  property for cash swap type swap type
//     * @param proposalId Id of the users proposal to be acted upon
//     * @param propertyId  the id of the property the user wants to buy
//     * @param biddingAmount  Amount the user is proposing
//     */
//    function _propertyForCash(uint256 proposalId, uint8 propertyId, uint256 biddingAmount) private {
//        MonopolyLibrary.SwappedType storage swappedSwapType = swappedType[proposalId];
//        swappedSwapType.propertyForCash.propertyId = propertyId;
//        swappedSwapType.propertyForCash.biddingAmount = biddingAmount;
//    }
//
//    /**
//     * @dev function that executes the  property and cash for property swap type swap type
//     * @param proposalId Id of the users proposal to be acted upon
//     * @param proposedPropertyId  the id of the property the user wants to buy
//     * @param proposedAmount Amount the user is proposing
//     * @param biddingPropertyId the id of the property the user wants to trade
//     */
//    function _propertyAndCashForProperty(
//        uint256 proposalId,
//        uint8 proposedPropertyId,
//        uint256 proposedAmount,
//        uint8 biddingPropertyId
//    ) private {
//        MonopolyLibrary.SwappedType storage swappedSwapType = swappedType[proposalId];
//        swappedSwapType.propertyAndCashForProperty.proposedPropertyId = proposedPropertyId;
//        swappedSwapType.propertyAndCashForProperty.proposedAmount = proposedAmount;
//        swappedSwapType.propertyAndCashForProperty.biddingPropertyId = biddingPropertyId;
//    }
//
//    /**
//     * @dev function that executes the  property for cash and property swap type swap type
//     * @param proposalId Id of the users proposal to be acted upon
//     * @param proposedPropertyId  the id of the property the user wants to buy
//     * @param biddingAmount  Amount the user is proposing
//     * @param biddingPropertyId the id of the property the user wants to trade
//     */
//    function _propertyForCashAndProperty(
//        uint256 proposalId,
//        uint8 proposedPropertyId,
//        uint8 biddingPropertyId,
//        uint256 biddingAmount
//    ) private {
//        MonopolyLibrary.SwappedType storage swappedSwapType = swappedType[proposalId];
//
//        swappedSwapType.propertyForCashAndProperty.proposedPropertyId = proposedPropertyId;
//        swappedSwapType.propertyForCashAndProperty.biddingPropertyId = biddingPropertyId;
//        swappedSwapType.propertyForCashAndProperty.biddingAmount = biddingAmount;
//    }
//
//    /**
//     * @dev function that executes the  property for property swap type swap type
//     * @param proposalId Id of the users proposal to be acted upon
//     * @param proposedPropertyId  the id of the property the user wants to buy
//     * @param biddingPropertyId the id of the property the user wants to trade
//     */
//    function _propertyForProperty(uint256 proposalId, uint8 proposedPropertyId, uint8 biddingPropertyId) private {
//        MonopolyLibrary.SwappedType storage swappedSwapType = swappedType[proposalId];
//        swappedSwapType.propertyForProperty.proposedPropertyId = proposedPropertyId;
//        swappedSwapType.propertyForProperty.biddingPropertyId = biddingPropertyId;
//    }
//
//    mapping(uint256 => bool) private isProposalActive;
//
//    /**
//     * @dev function that users use to either accept or reject proposal
//     * @param _user address of the user that wants to either accept or reject trade
//     * @param proposalId Id of the users proposal to be acted upon
//     * @param isAccepted a boolean that users pass to either accept or reject proposal
//     */
//    function makeDecisionOnProposal(address _user, uint256 proposalId, bool isAccepted) external nonReentrant {
//        require(isProposalActive[proposalId], "Proposal already decided");
//        MonopolyLibrary.Proposal storage proposal = inGameProposals[proposalId];
//        if (isAccepted) {
//            acceptProposal(_user, proposalId);
//        } else {
//            proposal.proposalStatus = MonopolyLibrary.ProposalStatus.REJECTED;
//        }
//
//        isProposalActive[proposalId] = false;
//    }
//
//    // in progress
//    // this state track the user to the proposalId to a boolean value
//    // mapping(uint8 => mapping(address => bool)) private userProposalExist;
//
//    /**
//     * @dev function that users use to accept proposal
//     * @param _user address of the user that wants to either accept or reject trade
//     * @param proposalId Id of the users proposal to be accepted
//     */
//    function acceptProposal(address _user, uint256 proposalId) private {
//        MonopolyLibrary.Proposal storage proposal = inGameProposals[proposalId];
//        MonopolyLibrary.SwappedType memory proposalSwappedType = swappedType[proposalId];
//
//        require(proposal.otherPlayer == _user, "proposal not to this user");
//
//        proposal.swapType == MonopolyLibrary.SwapType.PROPERTY_FOR_PROPERTY
//            ? _checkPropertyForProperty(proposalSwappedType, _user, proposal.player)
//            : proposal.swapType == MonopolyLibrary.SwapType.PROPERTY_FOR_CASH
//                ? _checkPropertyForCashAndProperty(proposalSwappedType, _user, proposal.player)
//                : proposal.swapType == MonopolyLibrary.SwapType.CASH_FOR_PROPERTY
//                    ? _checkPropertyAndCashForProperty(proposalSwappedType, _user, proposal.player)
//                    : proposal.swapType == MonopolyLibrary.SwapType.PROPERTY_FOR_CASH
//                        ? _checkPropertyForCash(proposalSwappedType, _user, proposal.player)
//                        : _checkCashForProperty(proposalSwappedType, _user, proposal.player);
//
//        proposal.proposalStatus = MonopolyLibrary.ProposalStatus.ACCEPTED;
//    }
//
//    function _checkCashForProperty(
//        MonopolyLibrary.SwappedType memory proposalSwappedType,
//        address _user,
//        address proposer
//    ) private {
//        uint256 amountInvolved = proposalSwappedType.cashForProperty.proposedAmount;
//        uint8 biddingPropertyId = proposalSwappedType.cashForProperty.biddingPropertyId;
//
//        require(balanceOf(proposer) >= amountInvolved, "");
//
//        _transfer(proposer, _user, amountInvolved);
//
//        MonopolyLibrary.PropertyG storage biddingProperty = gameProperties[biddingPropertyId];
//        propertyOwner[biddingPropertyId] = proposer;
//
//        //bidding
//        _handlePropertyTransfer(biddingProperty, _user, proposer);
//    }
//
//    function _checkPropertyForCash(
//        MonopolyLibrary.SwappedType memory proposalSwappedType,
//        address _user,
//        address proposer
//    ) private {
//        //        proposalSwappedType.
//        uint8 proposedPropertyId = proposalSwappedType.propertyForCash.propertyId;
//        uint256 amountInvolved = proposalSwappedType.propertyForCash.biddingAmount;
//
//        require(balanceOf(_user) >= amountInvolved, "");
//
//        _transfer(_user, proposer, amountInvolved);
//
//        MonopolyLibrary.PropertyG storage proposedProperty = gameProperties[proposedPropertyId];
//
//        propertyOwner[proposedPropertyId] = _user;
//
//        //proposed
//        _handlePropertyTransfer(proposedProperty, proposer, _user);
//    }
//
//    function _checkPropertyAndCashForProperty(
//        MonopolyLibrary.SwappedType memory proposalSwappedType,
//        address _user,
//        address proposer
//    ) private {
//        uint256 amountInvolve = proposalSwappedType.propertyAndCashForProperty.proposedAmount;
//        require(balanceOf(proposer) >= amountInvolve, "proposer does not hold such value at hand");
//
//        _transfer(proposer, _user, amountInvolve);
//
//        uint8 proposedPropertyId = proposalSwappedType.propertyAndCashForProperty.proposedPropertyId;
//        uint8 biddingPropertyId = proposalSwappedType.propertyForProperty.biddingPropertyId;
//
//        // do that
//        MonopolyLibrary.PropertyG storage proposedProperty = gameProperties[proposedPropertyId];
//        MonopolyLibrary.PropertyG storage biddingProperty = gameProperties[biddingPropertyId];
//
//        propertyOwner[biddingPropertyId] = proposer;
//        propertyOwner[proposedPropertyId] = _user;
//
//        //bidding
//        _handlePropertyTransfer(biddingProperty, _user, proposer);
//
//        //proposed
//        _handlePropertyTransfer(proposedProperty, proposer, _user);
//    }
//
//    function _checkPropertyForProperty(
//        MonopolyLibrary.SwappedType memory proposalSwappedType,
//        address _user,
//        address proposer
//    ) private {
//        // do this
//        uint8 proposedPropertyId = proposalSwappedType.propertyForProperty.proposedPropertyId;
//        uint8 biddingPropertyId = proposalSwappedType.propertyForProperty.biddingPropertyId;
//
//        // do that
//        MonopolyLibrary.PropertyG storage proposedProperty = gameProperties[proposedPropertyId];
//        MonopolyLibrary.PropertyG storage biddingProperty = gameProperties[biddingPropertyId];
//
//        propertyOwner[biddingPropertyId] = proposer;
//        propertyOwner[proposedPropertyId] = _user;
//
//        //bidding
//        _handlePropertyTransfer(biddingProperty, _user, proposer);
//
//        // proposed
//        _handlePropertyTransfer(proposedProperty, proposer, _user);
//    }
//
//    function _checkPropertyForCashAndProperty(
//        MonopolyLibrary.SwappedType memory proposalSwappedType,
//        address _user,
//        address proposer
//    ) private {
//        uint256 amountInvolved = proposalSwappedType.propertyForCashAndProperty.biddingAmount;
//        uint8 proposedPropertyId = proposalSwappedType.propertyForCashAndProperty.proposedPropertyId;
//        uint8 biddingPropertyId = proposalSwappedType.propertyForCashAndProperty.biddingPropertyId;
//
//        require(balanceOf(_user) >= amountInvolved, "");
//
//        _transfer(_user, proposer, amountInvolved);
//
//        MonopolyLibrary.PropertyG storage proposedProperty = gameProperties[proposedPropertyId];
//        MonopolyLibrary.PropertyG storage biddingProperty = gameProperties[biddingPropertyId];
//
//        propertyOwner[biddingPropertyId] = proposer;
//        propertyOwner[proposedPropertyId] = _user;
//
//        //bidding
//        _handlePropertyTransfer(biddingProperty, _user, proposer);
//
//        // proposed
//        _handlePropertyTransfer(proposedProperty, proposer, _user);
//    }
//
//    function _handlePropertyTransfer(MonopolyLibrary.PropertyG storage propertyG, address player1, address player2)
//        private
//    {
//        propertyG.owner = player2;
//        noOfColorGroupOwnedByUser[propertyG.propertyColor][player1] -= 1;
//        noOfColorGroupOwnedByUser[propertyG.propertyColor][player2] += 1;
//
//        if (propertyG.propertyType == MonopolyLibrary.PropertyType.RailStation) {
//            numberOfOwnedRailways[player1] -= 1;
//            numberOfOwnedRailways[player2] += 1;
//        }
//    }
//
//    mapping(address => uint8) private numberOfOwnedRailways;
//
//    function _checkRailStationRent(uint8 propertyId) private view returns (uint256) {
//        // console.log("property id is ::: ", propertyId);
//        address railOwner = propertyOwner[propertyId];
//        // console.log("address of owner is ::: ", railOwner);
//        // Count how many railway stations are owned by the player
//        uint8 ownedRailways = numberOfOwnedRailways[railOwner];
//        // console.log("owned number of rail is ::: ", ownedRailways);
//
//        return 25 * (2 ** (ownedRailways - 1));
//    }
//
//    function _checkUtilityRent(uint8 propertyId, uint256 diceRolled) private view returns (uint256) {
//        require(propertyId == 13 || propertyId == 29, "");
//
//        return propertyOwner[13] == propertyOwner[29] ? (diceRolled * 10) : (diceRolled * 4);
//    }
//
//    function handleRent(address player, uint8 propertyId, uint8 diceRolled) external nonReentrant {
//        // require(propertyId <= propertySize, "No property with the given ID");
//        require(!mortgagedProperties[propertyId], "Property is Mortgaged no rent");
//        MonopolyLibrary.PropertyG storage foundProperty = gameProperties[propertyId];
//        // are we paying for special properties ?
//        require(foundProperty.owner != address(this), "Property does not have an owner");
//        require(foundProperty.owner != player, "Player Owns Property no need for rent");
//
//        uint256 rentAmount;
//
//        // Check if the property is a Utility
//        if (foundProperty.propertyType == MonopolyLibrary.PropertyType.Utility) {
//            rentAmount = _checkUtilityRent(propertyId, diceRolled);
//        }
//        // Check if the property is a Rail Station
//        else if (foundProperty.propertyType == MonopolyLibrary.PropertyType.RailStation) {
//            rentAmount = _checkRailStationRent(propertyId);
//        }
//        // Regular Property Rent
//        else {
//            rentAmount = foundProperty.noOfUpgrades > 0
//                ? foundProperty.rentAmount * (2 ** (foundProperty.noOfUpgrades - 1))
//                : foundProperty.rentAmount;
//        }
//
//        // Transfer the rent to the owner
//        _transfer(player, foundProperty.owner, rentAmount);
//    }
//
//    function returnProposal(address user) external view returns (MonopolyLibrary.PropertySwap memory) {
//        MonopolyLibrary.PropertySwap memory deal = propertySwap[user];
//        return deal;
//    }
//
//    /**
//     * @dev looked this through , i think i am not getting the summation of the amount but formula is correct
//     */
//
//    // Function to mortgage a property
//    function mortgageProperty(uint8 propertyId, address player) external nonReentrant {
//        MonopolyLibrary.PropertyG memory property = gameProperties[propertyId];
//        require(!mortgagedProperties[propertyId], "Property is already Mortgaged");
//
//        require(property.owner == player, "You are not the owner of this property");
//        mortgagedProperties[propertyId] = true;
//
//        uint256 mortgageAmount = property.buyAmount / 2;
//        // Transfer funds to the owner
//        //        bool success = transferFrom(address(this), msg.sender, mortgageAmount);
//        //        require(success, "Token transfer failed");
//        _transfer(address(this), player, mortgageAmount);
//
//        emit PropertyMortgaged(propertyId, mortgageAmount, player);
//    }
//
//    // Function to release a mortgage
//    function releaseMortgage(uint8 propertyId, address player) external {
//        MonopolyLibrary.PropertyG memory property = gameProperties[propertyId];
//
//        require(property.owner == player, "You are not the owner of this property");
//        require(mortgagedProperties[propertyId], "Property is not Mortgaged");
//
//        // Transfer the repaid funds to the contract owner or use it for future logic
//
//        _transfer(player, address(this), (property.buyAmount / 2));
//
//        // Release the mortgage
//        mortgagedProperties[propertyId] = false;
//    }
//
//    /**
//     * @dev It's important to note that only properties can be upgraded and down graded railstations and companies cannot
//     *  a 2d mapping of string to address to number
//     *  we can upgrade the three at once
//     */
//    function upgradeProperty(uint8 propertyId, uint8 _noOfUpgrade, address player) external {
//        MonopolyLibrary.PropertyG storage property = gameProperties[propertyId];
//
//        require(property.owner == player, "You are not the owner of this property");
//        require(!mortgagedProperties[propertyId], "Property is Mortgaged cannot upgrade");
//        require(property.propertyType == MonopolyLibrary.PropertyType.Property, "Only properties can be upgraded");
//        require(_noOfUpgrade > 0 && _noOfUpgrade <= 5, "");
//        // require(noOfUpgrades[propertyId] <= 5, "Property at Max upgrade");
//
//        uint8 mustOwnedNumberOfSiteColor = upgradeUserPropertyColorOwnedNumber[property.propertyColor];
//
//        // Calculate the cost of one house
//        uint8 userColorGroupOwned = noOfColorGroupOwnedByUser[property.propertyColor][player];
//
//        require(userColorGroupOwned >= mustOwnedNumberOfSiteColor, "must own at least two/three site with same color ");
//        require(property.noOfUpgrades < 5, "reach the peak upgrade for this property ");
//        uint8 noOfUpgrade = property.noOfUpgrades + _noOfUpgrade;
//
//        require(noOfUpgrade <= 5, "upgrade exceed peak ");
//
//        uint256 amountToPay = property.buyAmount * (2 * (2 ** (noOfUpgrade - 1)));
//
//        require(balanceOf(player) >= amountToPay, "Insufficient funds to upgrade property");
//
//        //        bool success = transferFrom(msg.sender, address(this), amountToPay);
//        _transfer(player, address(this), amountToPay);
//
//        property.noOfUpgrades += _noOfUpgrade;
//
//        emit PropertyUpGraded(propertyId);
//    }
//
//    // make the game owner of the bank and hence owns the token
//    function downgradeProperty(uint8 propertyId, uint8 noOfDowngrade, address player) external {
//        MonopolyLibrary.PropertyG storage property = gameProperties[propertyId];
//
//        // Ensure the caller is the owner of the property
//        require(property.owner == player, "You are not the owner of this property");
//        require(property.noOfUpgrades > 0, "cannot downgrade site");
//        require(noOfDowngrade > 0 && noOfDowngrade <= property.noOfUpgrades, "cannot downgrade");
//
//        // Ensure the property is not mortgaged
//        require(!mortgagedProperties[propertyId], "Cannot downgrade a mortgaged property");
//
//        uint256 amountToReceive = property.buyAmount * (2 ** (noOfDowngrade - 1));
//
//        //        bool success = transfer(msg.sender, amountToReceive);
//        //        require(success, "");
//        _transfer(address(this), player, amountToReceive);
//
//        property.noOfUpgrades -= noOfDowngrade;
//        emit PropertyDownGraded(propertyId);
//    }
//
//    // for testing purpose
//    function bal(address addr) external view returns (uint256) {
//        uint256 a = balanceOf(addr);
//        return a;
//    }
//
//    function getProperty(uint8 propertyId) external view returns (MonopolyLibrary.PropertyG memory property) {
//        property = gameProperties[propertyId];
//        return property;
//    }
//
//    function getPropertyOwner(uint8 propertyId) external view returns (address _propertyOwner) {
//        MonopolyLibrary.PropertyG memory property = gameProperties[propertyId];
//        _propertyOwner = property.owner;
//        return _propertyOwner;
//    }
//
//    function viewDeals(address myDeals) public view returns (MonopolyLibrary.PropertySwap memory currentDeal) {
//        MonopolyLibrary.PropertySwap storage swap = propertySwap[myDeals];
//        currentDeal = swap;
//        return currentDeal;
//    }
//
//    function getPropertiesOwnedByAPlayer(address _playerAddress)
//        external
//        view
//        returns (MonopolyLibrary.PropertyG[] memory)
//    {
//        MonopolyLibrary.PropertyG[] memory playerProperties = new MonopolyLibrary.PropertyG[](propertySize);
//        uint8 count = 0;
//
//        for (uint8 i = 1; i <= propertySize; i++) {
//            if (gameProperties[i].owner == _playerAddress) {
//                playerProperties[count] = gameProperties[i];
//                count++;
//            }
//        }
//
//        assembly {
//            mstore(playerProperties, count)
//        }
//
//        return playerProperties;
//    }
//}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {ERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import {ReentrancyGuard} from "lib/openzeppelin-contracts/contracts/utils/ReentrancyGuard.sol";
import "./libraries/MonopolyLibrary.sol";
import "./libraries/GameBankLibrary.sol";

interface NFTContract {
    function getAllProperties() external view returns (MonopolyLibrary.Property[] memory);
}

contract GameBank is ERC20("GameBank", "GB"), ReentrancyGuard {
    using GameBankLibrary for GameBankLibrary.GameBankStorage;

    GameBankLibrary.GameBankStorage private s;

    event RentPaid(address tenant, address landlord, uint256 rentPrice, bytes property);
    event PropertyMortgaged(uint256 propertyId, uint256 mortgageAmount, address owner);
    event PropertyListedForSale(uint256 propertyId, uint256 propertyPrice, address owner);
    event PropertyUpGraded(uint256 propertyId);
    event PropertyDownGraded(uint256 propertyId);
    event PropertyBid(uint8 indexed propertyId, address indexed bidder, uint256 bidAmount);
    event PropertySold(uint8 indexed propertyId, address indexed newOwner, uint256 amount);

    constructor(uint8 numberOfPlayers, address _nftContract) {
        GameBankLibrary.initialize(s, numberOfPlayers, _nftContract);
        _mint(address(this), (numberOfPlayers + 4) * 1000);
    }

    function mint(address to, uint256 amount) external {
        _transfer(address(this), to, amount);
    }

    function mints(address[] memory to, uint256 amount) external {
        for (uint8 i = 0; i < to.length; i++) {
            _transfer(address(this), to[i], amount);
        }
    }

    function buyProperty(uint8 propertyId, address buyer) external nonReentrant {
        uint256 amount = GameBankLibrary.buyProperty(s, propertyId, buyer, balanceOf(buyer));
        _transfer(buyer, address(this), amount);
    }

    function makeProposal(
        address proposer,
        address otherPlayer,
        uint8 proposedPropertyId,
        uint8 biddingPropertyId,
        MonopolyLibrary.SwapType swapType,
        uint256 amountInvolved
    ) external {
        GameBankLibrary.makeProposal(s, proposer, otherPlayer, proposedPropertyId, biddingPropertyId, swapType, amountInvolved);
    }

    function makeDecisionOnProposal(address _user, uint256 proposalId, bool isAccepted) external nonReentrant {
        GameBankLibrary.makeDecisionOnProposal(s, _user, proposalId, isAccepted);
    }
    function handleRent(address player, uint8 propertyId, uint8 diceRolled) external nonReentrant {
        uint256 rentAmount = GameBankLibrary.handleRent(s, player, propertyId, diceRolled, balanceOf(player));
        _transfer(player, s.bankGameProperties[propertyId].owner, rentAmount);
        emit RentPaid(player, s.bankGameProperties[propertyId].owner, rentAmount, "");
    }
    function mortgageProperty(uint8 propertyId, address player) external nonReentrant {
        uint256 mortgageAmount = GameBankLibrary.mortgageProperty(s, propertyId, player, balanceOf(player));
        _transfer(address(this), player, mortgageAmount);
        emit PropertyMortgaged(propertyId, mortgageAmount, player);
    }
    function releaseMortgage(uint8 propertyId, address player) external {
        uint256 repaymentAmount = GameBankLibrary.releaseMortgage(s, propertyId, player, balanceOf(player));
        _transfer(player, address(this), repaymentAmount);
    }
    function upgradeProperty(uint8 propertyId, uint8 _noOfUpgrade, address player) external {
        uint256 amountToPay = GameBankLibrary.upgradeProperty(s, propertyId, _noOfUpgrade, player, balanceOf(player));
        _transfer(player, address(this), amountToPay);
        emit PropertyUpGraded(propertyId);
    }
    function downgradeProperty(uint8 propertyId, uint8 noOfDowngrade, address player) external {
        uint256 amountToReceive = GameBankLibrary.downgradeProperty(s, propertyId, noOfDowngrade, player);
        _transfer(address(this), player, amountToReceive);
        emit PropertyDownGraded(propertyId);
    }
    function getNumberOfUserOwnedPropertyOnAColor(address user, MonopolyLibrary.PropertyColors color) external view returns (uint8) {
        return GameBankLibrary.getNumberOfUserOwnedPropertyOnAColor(s, user, color);
    }
    function getProposalSwappedType(uint8 proposalId) external view returns (MonopolyLibrary.SwappedType memory) {
        return GameBankLibrary.getProposalSwappedType(s, proposalId);
    }
    function returnProposal(address user) external view returns (MonopolyLibrary.PropertySwap memory) {
        return GameBankLibrary.returnProposal(s, user);
    }
    function getProperty(uint8 propertyId) external view returns (MonopolyLibrary.PropertyG memory) {
        return s.bankGameProperties[propertyId];
    }
    function getPropertyOwner(uint8 propertyId) external view returns (address) {
        return s.bankGameProperties[propertyId].owner;
    }
    function getPropertiesOwnedByAPlayer(address _playerAddress) external view returns (MonopolyLibrary.PropertyG[] memory) {
        return GameBankLibrary.getPropertiesOwnedByAPlayer(s, _playerAddress);
    }
    function bal(address addr) external view returns (uint256) {
        return balanceOf(addr);
    }
}