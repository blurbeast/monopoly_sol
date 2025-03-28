// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.26;

import "./libraries/TokenLibrary.sol";

interface IGameToken {
    function mint(uint8 numberOfP, address contractAddress) external;
    function mintToPlayers(address[] memory players, uint256 amount, address contractAddress) external;
    function transfer(address gameId, address owner, address beneficiary, uint256 amount) external;
    function balanceOf(address owner, address contractAddress) external view returns (uint256);
    function approve(address gameId, address owner, address spender) external;
    function transferFrom(address gameId, address owner, address spender, address beneficiary, uint256 amount) external;
}

contract GameToken {
    using TokenLibrary for TokenLibrary.TokenStorage;

    TokenLibrary.TokenStorage private s;

    string public name = "Monopoly Token";
    string public symbol = "MPT";

    constructor() {
        s.gameToken = address(this);
    }

//    function state() external view returns(TokenLibrary.TokenStorage memory) {
//        return s;
//    }

    modifier onlyBankContract(address _address) {
        require(_address.code.length > 0, "Only contract address allowed");
        _;
    }

    function mint(uint8 numberOfP, address contractAddress) external {
        uint256 amount = (numberOfP + 4) * 1000;
        s.playerBalance[contractAddress][contractAddress] += amount;
    }

    function mintToPlayers(address[] memory players, uint256 amount, address contractAddress)
        external
        onlyBankContract(contractAddress)
    {
        for (uint8 i = 0; i < players.length; i++) {
            s.transfer(contractAddress, contractAddress, players[i], amount);
        }
    }

    function transfer(address gameId, address owner, address beneficiary, uint256 amount) external {
        s.transfer(gameId, owner, beneficiary, amount);
    }

    function balanceOf(address owner, address contractAddress) external view returns (uint256) {
        return s.balanceOf(owner, contractAddress);
    }

    function approve(address gameId, address owner, address spender) external {
        s.approve(gameId, owner, spender);
    }

    function transferFrom(address gameId, address owner, address spender, address beneficiary, uint256 amount)
        external
    {
        s.transferFrom(gameId, owner, spender, beneficiary, amount);
    }
}
