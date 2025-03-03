// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

interface ISmartAccount {
      function execute(address target , uint value,  bytes calldata data) external returns(bool, bytes memory);
      function nonce() external returns(uint256);
      function owner() external returns(address);
}