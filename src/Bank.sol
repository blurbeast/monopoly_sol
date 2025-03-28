// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {ReentrancyGuard} from "lib/openzeppelin-contracts/contracts/utils/ReentrancyGuard.sol";
import "./libraries/MonopolyLibrary.sol";
import "./libraries/GameBankLibrary.sol";
import "./libraries/TokenLibrary.sol";
import "./GameToken.sol";

interface NFTContract {
    function getAllProperties() external view returns (MonopolyLibrary.Property[] memory);
}

contract GameBank  {
    using GameBankLibrary for GameBankLibrary.GameBankStorage;
    using TokenLibrary for TokenLibrary.TokenStorage;

    GameBankLibrary.GameBankStorage private s;
    TokenLibrary.TokenStorage private tokenStorage;

    event RentPaid(address tenant, address landlord, uint256 rentPrice, bytes property);
    event PropertyMortgaged(uint256 propertyId, uint256 mortgageAmount, address owner);
    event PropertyUpGraded(uint256 propertyId);
    event PropertyDownGraded(uint256 propertyId);

    constructor(uint8 numberOfPlayers, address _nftContract, address gameToken) {
        GameBankLibrary.initialize(s, numberOfPlayers, _nftContract, gameToken);
        tokenStorage.gameToken = gameToken;
    }

    function mint(address to, uint256 amount) external {
        GameToken(tokenStorage.gameToken).mint(0, address(this)); // Adjust as needed
        tokenStorage.transfer(address(this), address(this), to, amount);
    }

    function mints(address[] memory to, uint256 amount) external {
        GameToken(tokenStorage.gameToken).mintToPlayers(to, amount, address(this));
    }

    function buyProperty(uint8 propertyId, address buyer) external  {
        uint256 amount = GameBankLibrary.buyProperty(s, propertyId, buyer, tokenStorage.balanceOf(buyer, address(this)));
        tokenStorage.transferFrom(address(this), buyer, address(this), address(this), amount);
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

    function makeDecisionOnProposal(address _user, uint256 proposalId, bool isAccepted) external  {
        GameBankLibrary.makeDecisionOnProposal(s, _user, proposalId, isAccepted);
    }

    function handleRent(address player, uint8 propertyId, uint8 diceRolled) external  {
        uint256 rentAmount = GameBankLibrary.handleRent(s, player, propertyId, diceRolled, tokenStorage.balanceOf(player, address(this)));
        tokenStorage.transferFrom(address(this), player, address(this), s.bankGameProperties[propertyId].owner, rentAmount);
        emit RentPaid(player, s.bankGameProperties[propertyId].owner, rentAmount, "");
    }

    function mortgageProperty(uint8 propertyId, address player) external  {
        uint256 mortgageAmount = GameBankLibrary.mortgageProperty(s, propertyId, player, tokenStorage.balanceOf(player, address(this)));
        tokenStorage.transfer(address(this), address(this), player, mortgageAmount);
        emit PropertyMortgaged(propertyId, mortgageAmount, player);
    }

    function releaseMortgage(uint8 propertyId, address player) external {
        uint256 repaymentAmount = GameBankLibrary.releaseMortgage(s, propertyId, player, tokenStorage.balanceOf(player, address(this)));
        tokenStorage.transferFrom(address(this), player, address(this), address(this), repaymentAmount);
    }

    function upgradeProperty(uint8 propertyId, uint8 _noOfUpgrade, address player) external {
        uint256 amountToPay = GameBankLibrary.upgradeProperty(s, propertyId, _noOfUpgrade, player, tokenStorage.balanceOf(player, address(this)));
        tokenStorage.transferFrom(address(this), player, address(this), address(this), amountToPay);
        emit PropertyUpGraded(propertyId);
    }

    function downgradeProperty(uint8 propertyId, uint8 noOfDowngrade, address player) external {
        uint256 amountToReceive = GameBankLibrary.downgradeProperty(s, propertyId, noOfDowngrade, player);
        tokenStorage.transfer(address(this), address(this), player, amountToReceive);
        emit PropertyDownGraded(propertyId);
    }

    // View functions remain unchanged
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
        return tokenStorage.balanceOf(addr, address(this));
    }
}