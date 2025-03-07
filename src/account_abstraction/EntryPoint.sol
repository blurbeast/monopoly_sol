//SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {IAccount} from "lib/account-abstraction/contracts/interfaces/IAccount.sol";
import {IPaymaster} from "lib/account-abstraction/contracts/interfaces/IPaymaster.sol";
import {ISmartAccount} from "./interfaces/ISmartAccount.sol";
import {PackedUserOperation} from "lib/account-abstraction/contracts/interfaces/PackedUserOperation.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract EntryPoint is ReentrancyGuard {
    function handleOp(PackedUserOperation calldata userOp, bytes32 userOpHash)
        external
        nonReentrant
        returns (bytes memory)
    {
        IAccount iAccount = IAccount(userOp.sender);

        uint256 gasCost = _estimateGasCost(userOp);

        uint256 validationData = iAccount.validateUserOp(userOp, userOpHash, gasCost);
        require(validationData == 0, "validation failed");

        if (userOp.paymasterAndData.length >= 20) {
            address paymaster = address(uint160(bytes20(userOp.paymasterAndData[0:20])));
            (bytes memory context, uint256 paymasterValidation) =
                IPaymaster(paymaster).validatePaymasterUserOp(userOp, userOpHash, 30);
            require(paymasterValidation == 0, "Paymaster validation failed");

            (, bytes memory data) = _execute(userOp);
            IPaymaster(paymaster).postOp(IPaymaster.PostOpMode.opSucceeded, context, gasleft(), 0);
            return data;
        } else {
            (, bytes memory data) = _execute(userOp);
            return data;
        }
    }

    function _estimateGasCost(PackedUserOperation calldata userOp) internal pure returns (uint256) {
        uint128 callGasLimit = uint128(uint256(userOp.accountGasLimits >> 128)); // First 16 bytes
        uint128 verificationGasLimit = uint128(uint256(userOp.accountGasLimits)); // Last 16 bytes

        // Extract maxFeePerGas and maxPriorityFeePerGas from gasFees
        uint128 maxFeePerGas = uint128(uint256(userOp.gasFees)); // First 16 bytes
        // uint128 maxPriorityFeePerGas = uint128(uint256(userOp.gasFees)); // Last 16 bytes

        // Calculate total gas cost
        uint256 totalGas = uint256(callGasLimit) + uint256(verificationGasLimit) + userOp.preVerificationGas;
        return totalGas * uint256(maxFeePerGas);
    }

    function _execute(PackedUserOperation calldata userOp) internal returns (bool, bytes memory) {
        (address target, uint256 value, bytes memory data) = abi.decode(userOp.callData, (address, uint256, bytes));

        (bool success, bytes memory responseData) = ISmartAccount(userOp.sender).execute(target, value, data);
        require(success, "Execution failed");
        return (success, responseData);
    }

    receive() external payable {}
}
