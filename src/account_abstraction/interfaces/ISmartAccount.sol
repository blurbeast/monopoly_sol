// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

interface ISmartAccount {
      function execute(address target , uint value,  bytes calldata data) external returns(bool, bytes memory);
}