// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "./MonopolyLibrary.sol";
import "../Bank.sol";
import { IGameToken } from "../GameToken.sol";

library GameBankLibrary {

    event RentPaid(address tenant, address landlord, uint256 rentPrice, bytes property);
    event PropertyMortgaged(uint256 propertyId, uint256 mortgageAmount, address owner);
    event PropertyUpGraded(uint256 propertyId);
    event PropertyDownGraded(uint256 propertyId);

    struct GameBankStorage {
        mapping(uint8 => address) propertyOwner;
        mapping(uint256 => bool) mortgagedProperties;
        mapping(uint8 => uint8) noOfUpgrades;
        mapping(MonopolyLibrary.PropertyColors => mapping(address => uint8)) noOfColorGroupOwnedByUser;
        mapping(MonopolyLibrary.PropertyColors => uint8) upgradeUserPropertyColorOwnedNumber;
        mapping(uint8 => MonopolyLibrary.PropertyG) bankGameProperties;
        mapping(address => MonopolyLibrary.PropertySwap) propertySwap;
        mapping(uint256 => MonopolyLibrary.Proposal) inGameProposals;
        mapping(uint8 => uint8) propertyToProposal;
        mapping(uint256 => MonopolyLibrary.SwappedType) swappedType;
        mapping(uint256 => bool) isProposalActive;
        mapping(address => uint8) numberOfOwnedRailways;
        uint8 propertySize;
        uint256 proposalIds;
        address nftContract;
        address gameToken;
        uint8 numberOfPlayer;
    }

    function initialize(GameBankStorage storage s, uint8 numberOfPlayers, address _nftContract, address _gameToken)
        internal
    {
        require(_nftContract.code.length > 0, "not a contract address");
        s.nftContract = _nftContract;
        s.numberOfPlayer = numberOfPlayers;
        s.gameToken = _gameToken;
        gameProperties(s);
        setNumberForColoredPropertyNumber(s);
        mintToBank(_gameToken, numberOfPlayers);
    }

    function mintToBank(address gameToken, uint8 numberOfPlayers) internal {
        IGameToken(gameToken).mint(numberOfPlayers, address (this));
    }

    function mintToBankGamePlayers(GameBankStorage storage s, address[] memory to, uint256 amount) internal {
        IGameToken(s.gameToken).mintToPlayers(to, amount, address(this));
    }

    function playerBankBalance(GameBankStorage storage s, address addr) internal returns (uint256) {
        return IGameToken(s.gameToken).balanceOf(addr, address(this));
    }

    function gameProperties(GameBankStorage storage s) internal {
        MonopolyLibrary.Property[] memory allProperties = NFTContract(s.nftContract).getAllProperties();
        s.propertySize = uint8(allProperties.length);
        for (uint8 i = 0; i < allProperties.length; i++) {
            s.bankGameProperties[i + 1] = MonopolyLibrary.PropertyG(
                allProperties[i].name,
                allProperties[i].uri,
                allProperties[i].buyAmount,
                allProperties[i].rentAmount,
                address(this),
                0,
                allProperties[i].propertyType,
                allProperties[i].color
            );
        }
    }

    function setNumberForColoredPropertyNumber(GameBankStorage storage s) internal {
        s.upgradeUserPropertyColorOwnedNumber[MonopolyLibrary.PropertyColors.PINK] = 3;
        s.upgradeUserPropertyColorOwnedNumber[MonopolyLibrary.PropertyColors.YELLOW] = 3;
        s.upgradeUserPropertyColorOwnedNumber[MonopolyLibrary.PropertyColors.BLUE] = 3;
        s.upgradeUserPropertyColorOwnedNumber[MonopolyLibrary.PropertyColors.ORANGE] = 3;
        s.upgradeUserPropertyColorOwnedNumber[MonopolyLibrary.PropertyColors.RED] = 3;
        s.upgradeUserPropertyColorOwnedNumber[MonopolyLibrary.PropertyColors.GREEN] = 3;
        s.upgradeUserPropertyColorOwnedNumber[MonopolyLibrary.PropertyColors.PURPLE] = 3;
        s.upgradeUserPropertyColorOwnedNumber[MonopolyLibrary.PropertyColors.BROWN] = 2;
    }

    function mint(GameBankStorage storage s, address to, uint256 amount)
        internal
    {
        IGameToken(s.gameToken).transfer(address(this), address(this), to, amount);
    }

    function buyProperty(
        GameBankStorage storage s,
        uint8 propertyId,
        address buyer
    ) internal {
        uint256 amount = buyPropertyLogic(s, propertyId, buyer, IGameToken(s.gameToken).balanceOf(buyer, address (this)));
        IGameToken(s.gameToken).transferFrom(address (this), buyer, address (this), address (this), amount);
    }

    function buyPropertyLogic(GameBankStorage storage s, uint8 propertyId, address buyer, uint256 balance)
        private
        returns (uint256)
    {
        MonopolyLibrary.PropertyG storage property = s.bankGameProperties[propertyId];
        require(property.propertyType != MonopolyLibrary.PropertyType.Special, "Invalid property, could not be bought");
        require(property.owner != buyer, "You already own the property");
        require(balance >= property.buyAmount, "insufficient balance");
        require(property.owner == address(this), "already owned by a player");

        property.owner = buyer;
        s.propertyOwner[propertyId] = buyer;
        s.noOfColorGroupOwnedByUser[property.propertyColor][buyer] += 1;
        if (property.propertyType == MonopolyLibrary.PropertyType.RailStation) {
            s.numberOfOwnedRailways[buyer] += 1;
        }
        return property.buyAmount;
    }

    function makeProposal(
        GameBankStorage storage s,
        address proposer,
        address otherPlayer,
        uint8 proposedPropertyId,
        uint8 biddingPropertyId,
        MonopolyLibrary.SwapType swapType,
        uint256 amountInvolved
    ) internal {
        address realOwner = s.propertyOwner[proposedPropertyId];
        require(realOwner == proposer, "asset specified is not owned by player");
        require(!s.mortgagedProperties[proposedPropertyId], "asset on mortgage");
        if (biddingPropertyId > 0) {
            require(!s.mortgagedProperties[biddingPropertyId], "bidding property is on mortgage");
        }

        s.proposalIds += 1;
        MonopolyLibrary.Proposal storage proposal = s.inGameProposals[s.proposalIds];
        proposal.swapType = swapType;
        proposal.otherPlayer = otherPlayer;
        proposal.player = proposer;

        if (swapType == MonopolyLibrary.SwapType.PROPERTY_FOR_PROPERTY) {
            propertyForProperty(s, s.proposalIds, proposedPropertyId, biddingPropertyId);
        } else if (swapType == MonopolyLibrary.SwapType.PROPERTY_FOR_CASH_AND_PROPERTY) {
            propertyForCashAndProperty(s, s.proposalIds, proposedPropertyId, biddingPropertyId, amountInvolved);
        } else if (swapType == MonopolyLibrary.SwapType.PROPERTY_AND_CASH_FOR_PROPERTY) {
            propertyAndCashForProperty(s, s.proposalIds, proposedPropertyId, amountInvolved, biddingPropertyId);
        } else if (swapType == MonopolyLibrary.SwapType.PROPERTY_FOR_CASH) {
            propertyForCash(s, s.proposalIds, proposedPropertyId, amountInvolved);
        } else {
            cashForProperty(s, s.proposalIds, amountInvolved, biddingPropertyId);
        }

        s.isProposalActive[s.proposalIds] = true;
    }

    function propertyForProperty(
        GameBankStorage storage s,
        uint256 proposalId,
        uint8 proposedPropertyId,
        uint8 biddingPropertyId
    ) internal {
        s.swappedType[proposalId].propertyForProperty.proposedPropertyId = proposedPropertyId;
        s.swappedType[proposalId].propertyForProperty.biddingPropertyId = biddingPropertyId;
    }

    function propertyForCashAndProperty(
        GameBankStorage storage s,
        uint256 proposalId,
        uint8 proposedPropertyId,
        uint8 biddingPropertyId,
        uint256 biddingAmount
    ) internal {
        s.swappedType[proposalId].propertyForCashAndProperty.proposedPropertyId = proposedPropertyId;
        s.swappedType[proposalId].propertyForCashAndProperty.biddingPropertyId = biddingPropertyId;
        s.swappedType[proposalId].propertyForCashAndProperty.biddingAmount = biddingAmount;
    }

    function propertyAndCashForProperty(
        GameBankStorage storage s,
        uint256 proposalId,
        uint8 proposedPropertyId,
        uint256 proposedAmount,
        uint8 biddingPropertyId
    ) internal {
        s.swappedType[proposalId].propertyAndCashForProperty.proposedPropertyId = proposedPropertyId;
        s.swappedType[proposalId].propertyAndCashForProperty.proposedAmount = proposedAmount;
        s.swappedType[proposalId].propertyAndCashForProperty.biddingPropertyId = biddingPropertyId;
    }

    function propertyForCash(GameBankStorage storage s, uint256 proposalId, uint8 propertyId, uint256 biddingAmount)
        internal
    {
        s.swappedType[proposalId].propertyForCash.propertyId = propertyId;
        s.swappedType[proposalId].propertyForCash.biddingAmount = biddingAmount;
    }

    function cashForProperty(
        GameBankStorage storage s,
        uint256 proposalId,
        uint256 proposedAmount,
        uint8 biddingPropertyId
    ) internal {
        s.swappedType[proposalId].cashForProperty.proposedAmount = proposedAmount;
        s.swappedType[proposalId].cashForProperty.biddingPropertyId = biddingPropertyId;
    }

    function makeDecisionOnProposal(GameBankStorage storage s, address _user, uint256 proposalId, bool isAccepted)
        internal
    {
        require(s.isProposalActive[proposalId], "Proposal already decided");
        MonopolyLibrary.Proposal storage proposal = s.inGameProposals[proposalId];
        if (isAccepted) {
            acceptProposal(s, _user, proposalId);
        } else {
            proposal.proposalStatus = MonopolyLibrary.ProposalStatus.REJECTED;
        }
        s.isProposalActive[proposalId] = false;
    }

    function acceptProposal(GameBankStorage storage s, address _user, uint256 proposalId) internal {
        MonopolyLibrary.Proposal storage proposal = s.inGameProposals[proposalId];
        MonopolyLibrary.SwappedType memory proposalSwappedType = s.swappedType[proposalId];
        require(proposal.otherPlayer == _user, "proposal not to this user");

        if (proposal.swapType == MonopolyLibrary.SwapType.PROPERTY_FOR_PROPERTY) {
            checkPropertyForProperty(s, proposalSwappedType, _user, proposal.player);
        } else if (proposal.swapType == MonopolyLibrary.SwapType.PROPERTY_FOR_CASH) {
            checkPropertyForCash(s, proposalSwappedType, _user, proposal.player);
        } else if (proposal.swapType == MonopolyLibrary.SwapType.CASH_FOR_PROPERTY) {
            checkCashForProperty(s, proposalSwappedType, _user, proposal.player);
        } else if (proposal.swapType == MonopolyLibrary.SwapType.PROPERTY_AND_CASH_FOR_PROPERTY) {
            checkPropertyAndCashForProperty(s, proposalSwappedType, _user, proposal.player);
        } else {
            checkPropertyForCashAndProperty(s, proposalSwappedType, _user, proposal.player);
        }
        proposal.proposalStatus = MonopolyLibrary.ProposalStatus.ACCEPTED;
    }

    function checkCashForProperty(
        GameBankStorage storage s,
        MonopolyLibrary.SwappedType memory proposalSwappedType,
        address _user,
        address proposer
    ) internal {
        uint256 amountInvolved = proposalSwappedType.cashForProperty.proposedAmount;
        uint8 biddingPropertyId = proposalSwappedType.cashForProperty.biddingPropertyId;
        MonopolyLibrary.PropertyG storage biddingProperty = s.bankGameProperties[biddingPropertyId];
        s.propertyOwner[biddingPropertyId] = proposer;
        handlePropertyTransfer(s, biddingProperty, _user, proposer);
    }

    function checkPropertyForCash(
        GameBankStorage storage s,
        MonopolyLibrary.SwappedType memory proposalSwappedType,
        address _user,
        address proposer
    ) internal {
        uint8 proposedPropertyId = proposalSwappedType.propertyForCash.propertyId;
        MonopolyLibrary.PropertyG storage proposedProperty = s.bankGameProperties[proposedPropertyId];
        s.propertyOwner[proposedPropertyId] = _user;
        handlePropertyTransfer(s, proposedProperty, proposer, _user);
    }

    function checkPropertyAndCashForProperty(
        GameBankStorage storage s,
        MonopolyLibrary.SwappedType memory proposalSwappedType,
        address _user,
        address proposer
    ) internal {
        uint8 proposedPropertyId = proposalSwappedType.propertyAndCashForProperty.proposedPropertyId;
        uint8 biddingPropertyId = proposalSwappedType.propertyAndCashForProperty.biddingPropertyId;
        MonopolyLibrary.PropertyG storage proposedProperty = s.bankGameProperties[proposedPropertyId];
        MonopolyLibrary.PropertyG storage biddingProperty = s.bankGameProperties[biddingPropertyId];
        s.propertyOwner[biddingPropertyId] = proposer;
        s.propertyOwner[proposedPropertyId] = _user;
        handlePropertyTransfer(s, biddingProperty, _user, proposer);
        handlePropertyTransfer(s, proposedProperty, proposer, _user);
    }

    function checkPropertyForProperty(
        GameBankStorage storage s,
        MonopolyLibrary.SwappedType memory proposalSwappedType,
        address _user,
        address proposer
    ) internal {
        uint8 proposedPropertyId = proposalSwappedType.propertyForProperty.proposedPropertyId;
        uint8 biddingPropertyId = proposalSwappedType.propertyForProperty.biddingPropertyId;
        MonopolyLibrary.PropertyG storage proposedProperty = s.bankGameProperties[proposedPropertyId];
        MonopolyLibrary.PropertyG storage biddingProperty = s.bankGameProperties[biddingPropertyId];
        s.propertyOwner[biddingPropertyId] = proposer;
        s.propertyOwner[proposedPropertyId] = _user;
        handlePropertyTransfer(s, biddingProperty, _user, proposer);
        handlePropertyTransfer(s, proposedProperty, proposer, _user);
    }

    function checkPropertyForCashAndProperty(
        GameBankStorage storage s,
        MonopolyLibrary.SwappedType memory proposalSwappedType,
        address _user,
        address proposer
    ) internal {
        uint8 proposedPropertyId = proposalSwappedType.propertyForCashAndProperty.proposedPropertyId;
        uint8 biddingPropertyId = proposalSwappedType.propertyForCashAndProperty.biddingPropertyId;
        MonopolyLibrary.PropertyG storage proposedProperty = s.bankGameProperties[proposedPropertyId];
        MonopolyLibrary.PropertyG storage biddingProperty = s.bankGameProperties[biddingPropertyId];
        s.propertyOwner[biddingPropertyId] = proposer;
        s.propertyOwner[proposedPropertyId] = _user;
        handlePropertyTransfer(s, biddingProperty, _user, proposer);
        handlePropertyTransfer(s, proposedProperty, proposer, _user);
    }

    function handlePropertyTransfer(
        GameBankStorage storage s,
        MonopolyLibrary.PropertyG storage propertyG,
        address player1,
        address player2
    ) internal {
        propertyG.owner = player2;
        s.noOfColorGroupOwnedByUser[propertyG.propertyColor][player1] -= 1;
        s.noOfColorGroupOwnedByUser[propertyG.propertyColor][player2] += 1;
        if (propertyG.propertyType == MonopolyLibrary.PropertyType.RailStation) {
            s.numberOfOwnedRailways[player1] -= 1;
            s.numberOfOwnedRailways[player2] += 1;
        }
    }

    function handleRentAndEmit(
        GameBankStorage storage s,
        address player,
        uint8 propertyId,
        uint8 diceRolled
    ) internal {
        uint256 rentAmount =
            handleRent(s, player, propertyId, diceRolled, IGameToken(s.gameToken).balanceOf(player, address(this)));
        IGameToken(s.gameToken).transferFrom(
            address(this), player, address(this), s.bankGameProperties[propertyId].owner, rentAmount
        );
        emit RentPaid(player, s.bankGameProperties[propertyId].owner, rentAmount, "");
    }

    function handleRent(GameBankStorage storage s, address player, uint8 propertyId, uint8 diceRolled, uint256 balance)
        internal
        returns (uint256)
    {
        require(!s.mortgagedProperties[propertyId], "Property is Mortgaged no rent");
        MonopolyLibrary.PropertyG storage foundProperty = s.bankGameProperties[propertyId];
        require(foundProperty.owner != address(this), "Property does not have an owner");
        require(foundProperty.owner != player, "Player Owns Property no need for rent");

        uint256 rentAmount;
        if (foundProperty.propertyType == MonopolyLibrary.PropertyType.Utility) {
            rentAmount = checkUtilityRent(s, propertyId, diceRolled);
        } else if (foundProperty.propertyType == MonopolyLibrary.PropertyType.RailStation) {
            rentAmount = checkRailStationRent(s, propertyId);
        } else {
            rentAmount = foundProperty.noOfUpgrades > 0
                ? foundProperty.rentAmount * (2 ** (foundProperty.noOfUpgrades - 1))
                : foundProperty.rentAmount;
        }
        require(balance >= rentAmount, "Insufficient balance for rent");
        return rentAmount;
    }

    function checkRailStationRent(GameBankStorage storage s, uint8 propertyId) internal view returns (uint256) {
        address railOwner = s.propertyOwner[propertyId];
        uint8 ownedRailways = s.numberOfOwnedRailways[railOwner];
        return 25 * (2 ** (ownedRailways - 1));
    }

    function checkUtilityRent(GameBankStorage storage s, uint8 propertyId, uint256 diceRolled)
        internal
        view
        returns (uint256)
    {
        require(propertyId == 13 || propertyId == 29, "Not a utility");
        return s.propertyOwner[13] == s.propertyOwner[29] ? (diceRolled * 10) : (diceRolled * 4);
    }

    function mortgagePropertyAndEmit(
        GameBankStorage storage s,
        uint8 propertyId,
        address player
    ) internal {
        uint256 mortgageAmount = mortgageProperty(s, propertyId, player, IGameToken(s.gameToken).balanceOf(player, address(this)));
        IGameToken(s.gameToken).transfer(address(this), address(this), player, mortgageAmount);
        emit PropertyMortgaged(propertyId, mortgageAmount, player);
    }

    function mortgageProperty(GameBankStorage storage s, uint8 propertyId, address player, uint256 balance)
        internal
        returns (uint256)
    {
        MonopolyLibrary.PropertyG memory property = s.bankGameProperties[propertyId];
        require(!s.mortgagedProperties[propertyId], "Property is already Mortgaged");
        require(property.owner == player, "You are not the owner of this property");
        s.mortgagedProperties[propertyId] = true;
        uint256 mortgageAmount = property.buyAmount / 2;
        return mortgageAmount;
    }

    function releaseMortgageAndTransfer(
        GameBankStorage storage s,
        uint8 propertyId,
        address player
    ) internal {
        uint256 repaymentAmount = releaseMortgage(s, propertyId, player, IGameToken(s.gameToken).balanceOf(player, address(this)));
        IGameToken(s.gameToken).transferFrom(address(this), player, address(this), address(this), repaymentAmount);
    }

    function releaseMortgage(GameBankStorage storage s, uint8 propertyId, address player, uint256 balance)
        internal
        returns (uint256)
    {
        MonopolyLibrary.PropertyG memory property = s.bankGameProperties[propertyId];
        require(property.owner == player, "You are not the owner of this property");
        require(s.mortgagedProperties[propertyId], "Property is not Mortgaged");
        uint256 repaymentAmount = property.buyAmount / 2;
        require(balance >= repaymentAmount, "Insufficient funds to release mortgage");
        s.mortgagedProperties[propertyId] = false;
        return repaymentAmount;
    }

    function upgradePropertyAndEmit(
        GameBankStorage storage s,
        uint8 propertyId,
        uint8 _noOfUpgrade,
        address player
    ) internal {
        uint256 amountToPay =
            upgradeProperty(s, propertyId, _noOfUpgrade, player, IGameToken(s.gameToken).balanceOf(player, address(this)));
        IGameToken(s.gameToken).transferFrom(address(this), player, address(this), address(this), amountToPay);
        emit PropertyUpGraded(propertyId);
    }

    function upgradeProperty(
        GameBankStorage storage s,
        uint8 propertyId,
        uint8 _noOfUpgrade,
        address player,
        uint256 balance
    ) internal returns (uint256) {
        MonopolyLibrary.PropertyG storage property = s.bankGameProperties[propertyId];
        require(property.owner == player, "You are not the owner of this property");
        require(!s.mortgagedProperties[propertyId], "Property is Mortgaged cannot upgrade");
        require(property.propertyType == MonopolyLibrary.PropertyType.Property, "Only properties can be upgraded");
        require(_noOfUpgrade > 0 && _noOfUpgrade <= 5, "Invalid upgrade number");
        uint8 mustOwnedNumberOfSiteColor = s.upgradeUserPropertyColorOwnedNumber[property.propertyColor];
        uint8 userColorGroupOwned = s.noOfColorGroupOwnedByUser[property.propertyColor][player];
        require(userColorGroupOwned >= mustOwnedNumberOfSiteColor, "must own at least two/three site with same color");
        require(property.noOfUpgrades < 5, "reach the peak upgrade for this property");
        uint8 noOfUpgrade = property.noOfUpgrades + _noOfUpgrade;
        require(noOfUpgrade <= 5, "upgrade exceed peak");
        uint256 amountToPay = property.buyAmount * (2 * (2 ** (noOfUpgrade - 1)));
        require(balance >= amountToPay, "Insufficient funds to upgrade property");
        property.noOfUpgrades += _noOfUpgrade;
        return amountToPay;
    }

    function downgradePropertyAndEmit(
        GameBankStorage storage s,
        uint8 propertyId,
        uint8 noOfDowngrade,
        address player
    ) internal {
        uint256 amountToReceive = downgradeProperty(s, propertyId, noOfDowngrade, player);
        IGameToken(s.gameToken).transfer(address(this), address(this), player, amountToReceive);
        emit PropertyDownGraded(propertyId);
    }

    function downgradeProperty(GameBankStorage storage s, uint8 propertyId, uint8 noOfDowngrade, address player)
        internal
        returns (uint256)
    {
        MonopolyLibrary.PropertyG storage property = s.bankGameProperties[propertyId];
        require(property.owner == player, "You are not the owner of this property");
        require(property.noOfUpgrades > 0, "cannot downgrade site");
        require(noOfDowngrade > 0 && noOfDowngrade <= property.noOfUpgrades, "cannot downgrade");
        require(!s.mortgagedProperties[propertyId], "Cannot downgrade a mortgaged property");
        uint256 amountToReceive = property.buyAmount * (2 ** (noOfDowngrade - 1));
        property.noOfUpgrades -= noOfDowngrade;
        return amountToReceive;
    }

    function getNumberOfUserOwnedPropertyOnAColor(
        GameBankStorage storage s,
        address user,
        MonopolyLibrary.PropertyColors color
    ) internal view returns (uint8) {
        return s.noOfColorGroupOwnedByUser[color][user];
    }

    function getProposalSwappedType(GameBankStorage storage s, uint8 proposalId)
        internal
        view
        returns (MonopolyLibrary.SwappedType memory)
    {
        return s.swappedType[proposalId];
    }

    function returnProposal(GameBankStorage storage s, address user)
        internal
        view
        returns (MonopolyLibrary.PropertySwap memory)
    {
        return s.propertySwap[user];
    }

    function getAllBankProperties(GameBankStorage storage s) internal view returns(MonopolyLibrary.PropertyG[] memory) {
        return bankProperties(s);
    }

    function bankProperties(GameBankStorage storage s) private view returns(MonopolyLibrary.PropertyG[] memory) {
        MonopolyLibrary.PropertyG[] memory allProperties = new MonopolyLibrary.PropertyG[](s.propertySize);
        uint8 count = 0;
        for (uint8 i = 1; i <= s.propertySize; i++) {
            allProperties[count] = s.bankGameProperties[i];
            count++;
        }
        assembly {
            mstore(allProperties, count)
        }

        return allProperties;
    }

    function getPropertiesOwnedByAPlayer(GameBankStorage storage s, address _playerAddress)
        internal
        view
        returns (MonopolyLibrary.PropertyG[] memory)
    {
//        for (uint8 i = 1; i <= s.propertySize; i++) {
//            if (s.bankGameProperties[i].owner == _playerAddress) {
//                playerProperties[count] = s.bankGameProperties[i];
//                count++;
//            }
//        }
//        assembly {
//            mstore(playerProperties, count)
//        }
        MonopolyLibrary.PropertyG[] memory allProperties = bankProperties(s);
        MonopolyLibrary.PropertyG[] memory playerProperties = new MonopolyLibrary.PropertyG[](s.propertySize);
        uint8 count = 0;
        for (uint8 i = 1; i <= s.propertySize; i++) {
            if (allProperties[i].owner == _playerAddress) {
                playerProperties[count] = s.bankGameProperties[i];
                count++;
            }
        }
        return playerProperties;
    }
}
