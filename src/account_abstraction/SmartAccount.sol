//SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {MessageHashUtils} from "../../lib/openzeppelin-contracts/contracts/utils/cryptography/MessageHashUtils.sol";
import {ECDSA} from "../../lib/openzeppelin-contracts/contracts/utils/cryptography/ECDSA.sol";
import {IAccount} from "lib/account-abstraction/contracts/interfaces/IAccount.sol";
import {PackedUserOperation} from "lib/account-abstraction/contracts/interfaces/PackedUserOperation.sol";
import {console} from "forge-std/Test.sol";

contract SmartAccount is IAccount {
    using ECDSA for bytes32;

    address public owner;
    address public entryPoint;
    uint256 public nonce;
    bytes32 private secretKey;

    constructor(address _owner, address _entryPoint, bytes memory _secretKey) {
        owner = _owner;
        entryPoint = _entryPoint;
        secretKey = keccak256(_secretKey);
    }

    function validateUserOp(PackedUserOperation calldata userOp, bytes32 userOpHash, uint256 missingAccountFunds)
        external
        returns (uint256 validationData)
    {
        require(userOp.nonce == nonce, "invalid user nonce");
        // bytes32 signedHash = MessageHashUtils.toEthSignedMessageHash(userOpHash);
        // address recoveredSigner = signedHash.recover(userOp.signature);

        if (secretKey != keccak256(userOp.signature)) {
            return 1;
        }
        nonce++;

        return 0;
    }

    function execute(address _target, uint256 value, bytes memory data) external returns (bool, bytes memory) {
        (bool success, bytes memory result) = _target.call{value: value}(data);

        require(success, "could not complete action");

        return (success, result);
    }

    receive() external payable {}
}
