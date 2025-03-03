


// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;


contract TestContract {

    uint256 public count;

    function setCount(uint256 _count) external {
        count = _count;
    }

    function incrementCount() external {
        count ++ ;
    }
}