
//SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

// import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC20} from "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";


contract Token is ERC20 {

    address public owner;
    address private tempOwner;


    constructor(address _owner) ERC20("Token", "TKN") {
        owner = _owner;
    }

    function changeOwnership(address _newOwner) external {
        require(msg.sender == owner, "not the owner");
        require(_newOwner != address(0), "zero address");
        tempOwner = _newOwner;
    }

    function acceptOwnership() external {
        require(msg.sender == tempOwner, "not the new owner");
        owner = tempOwner;
        tempOwner = address(0);
    }

    function collectToken(address _to) external {
        
        require(_to.code.length > 0, "must be a smart account");

        require(balanceOf(_to) <= 500, "not qualified for a new balance");

        _mint(_to, 1_000_000);
    }


    function mint(address _to, uint256 _amount) external {
        require(msg.sender == owner, "not the owner");
        _mint(_to, _amount);
    }
}