// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;
import {ERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract GameToken {
    // since this contract will be generic for all games , we'd create it in such a way to allow user balance at a particular game be used
    mapping(address => mapping(address => uint256 )) public playerBalance;
    mapping(address => mapping(address => mapping(address => uint256))) public allowance;

    string public name;
    string public symbol;
    constructor() {
        name = "Monopoly Token";
        symbol = "MPT";
    }

     modifier onlyBankContract(address _address) {
         require(_address.code.length > 0, "only contract address allowed");
         _;
     }

    function mint(uint8 numberOfP, address contractAddress) onlyBankContract(contractAddress) external {
        uint256 amount = (numberOfP + 4) * 1000;
        playerBalance[contractAddress][contractAddress] += amount;
    }

    function mintToPlayers(address[] memory players, uint256 amount, address contractAddress) external {
        for(uint8 i = 0; i < players.length; i++ ) {
            this.transfer(contractAddress, contractAddress, players[i], amount);
        }
    }

    function transfer(address gameId, address owner , address beneficiary, uint256 amount) public {
        // before transfer check the balance of the owner
        if (owner.code.length < 1) {
            // check balance of player
            uint256 bal = this.balanceOf(owner, gameId);
            require(bal >= amount, "insufficient balance");
            playerBalance[gameId][owner] -= amount;
            playerBalance[gameId][beneficiary] += amount;
        }else {
            uint256 bal = this.balanceOf(owner, gameId);
            require(bal >= amount, "insufficient balance");
            playerBalance[gameId][owner] -= amount;
            playerBalance[gameId][beneficiary] += amount;
        }
    }

    function balanceOf(address owner, address contractAddress) public returns(uint256) {
        return playerBalance[contractAddress][owner];
    }

    function approve(address gameId, address owner, address spender) external {
        //we are approving the total uint256 max
        // the approve is just adding a kinda layer
        allowance[gameId][owner][spender] = type(uint256).max;
    }

    function transferFrom(address gamesId, address owner, address spender, address beneficiary, uint256 amount) external {
        uint256 allow = allowance[gamesId][owner][spender];

        require(allow >= amount, "");

        playerBalance[gamesId][owner] -= amount;
        playerBalance[gamesId][beneficiary] += amount;
    }
}
