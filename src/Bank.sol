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

contract GameBank is ReentrancyGuard {
    using GameBankLibrary for GameBankLibrary.GameBankStorage;
//    using TokenLibrary for TokenLibrary.TokenStorage;

    GameBankLibrary.GameBankStorage private s;
    TokenLibrary.TokenStorage private tokenStorage;

    constructor(uint8 numberOfPlayers, address _nftContract, address gameToken) {
        GameBankLibrary.initialize(s, numberOfPlayers, _nftContract, gameToken);
        tokenStorage.gameToken = gameToken;
        GameToken(gameToken).mint(numberOfPlayers, address (this));
    }

    function mint(address to, uint256 amount) external {
        GameToken(tokenStorage.gameToken).mint(0, address(this));
        GameBankLibrary.mint(s, tokenStorage, to, amount);
    }

    function mints(address[] memory to, uint256 amount) external {
        GameToken(tokenStorage.gameToken).mintToPlayers(to, amount, address(this));
    }

    function buyProperty(uint8 propertyId, address buyer) external nonReentrant {
        GameBankLibrary.buyProperty(s, tokenStorage, propertyId, buyer, address(this));
    }

    function makeProposal(
        address proposer,
        address otherPlayer,
        uint8 proposedPropertyId,
        uint8 biddingPropertyId,
        MonopolyLibrary.SwapType swapType,
        uint256 amountInvolved
    ) external {
        GameBankLibrary.makeProposal(
            s, proposer, otherPlayer, proposedPropertyId, biddingPropertyId, swapType, amountInvolved
        );
    }

    function makeDecisionOnProposal(address _user, uint256 proposalId, bool isAccepted) external nonReentrant {
        GameBankLibrary.makeDecisionOnProposal(s, _user, proposalId, isAccepted);
    }

    function handleRent(address player, uint8 propertyId, uint8 diceRolled) external nonReentrant {
        GameBankLibrary.handleRentAndEmit(s, tokenStorage, player, propertyId, diceRolled);
    }

    function mortgageProperty(uint8 propertyId, address player) external nonReentrant {
        GameBankLibrary.mortgagePropertyAndEmit(s, tokenStorage, propertyId, player);
    }

    function releaseMortgage(uint8 propertyId, address player) external nonReentrant {
        GameBankLibrary.releaseMortgageAndTransfer(s, tokenStorage, propertyId, player);
    }

    function upgradeProperty(uint8 propertyId, uint8 _noOfUpgrade, address player) external nonReentrant {
        GameBankLibrary.upgradePropertyAndEmit(s, tokenStorage, propertyId, _noOfUpgrade, player);
    }

    function downgradeProperty(uint8 propertyId, uint8 noOfDowngrade, address player) external nonReentrant {
        GameBankLibrary.downgradePropertyAndEmit(s, tokenStorage, propertyId, noOfDowngrade, player);
    }

    function getNumberOfUserOwnedPropertyOnAColor(address user, MonopolyLibrary.PropertyColors color)
        external
        view
        returns (uint8)
    {
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

    function getPropertiesOwnedByAPlayer(address _playerAddress)
        external
        view
        returns (MonopolyLibrary.PropertyG[] memory)
    {
        return GameBankLibrary.getPropertiesOwnedByAPlayer(s, _playerAddress);
    }

    function bal(address addr) external view returns (uint256) {
        return tokenStorage.balanceOf(addr, address(this));
    }
}
