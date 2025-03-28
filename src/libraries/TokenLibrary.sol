// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

library TokenLibrary {
    struct TokenStorage {
        mapping(address => mapping(address => uint256)) playerBalance;
        mapping(address => mapping(address => mapping(address => uint256))) allowance;
        address gameToken;
    }

    function transfer(TokenStorage storage s, address gameId, address from, address to, uint256 amount) internal {
        uint256 bal = s.playerBalance[gameId][from];
        require(bal >= amount, "Insufficient balance");
        s.playerBalance[gameId][from] -= amount;
        s.playerBalance[gameId][to] += amount;
    }

    function transferFrom(
        TokenStorage storage s,
        address gameId,
        address owner,
        address spender,
        address to,
        uint256 amount
    ) internal {
        uint256 allow = s.allowance[gameId][owner][spender];
        require(allow >= amount, "Insufficient allowance");
//        if (allow != type(uint256).max) {
//            s.allowance[gameId][owner][spender] -= amount;
//        }
        transfer(s, gameId, owner, to, amount);
    }

    function approve(TokenStorage storage s, address gameId, address owner, address spender) internal {
        s.allowance[gameId][owner][spender] = type(uint256).max;
    }

    function balanceOf(TokenStorage storage s, address owner, address gameId) internal view returns (uint256) {
        return s.playerBalance[gameId][owner];
    }
}
