//SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {IAccount} from "lib/account-abstraction/contracts/interfaces/IAccount.sol";
import {IPaymaster} from "lib/account-abstraction/contracts/interfaces/IPaymaster.sol";
import {ISmartAccount} from "./interfaces/ISmartAccount.sol";
import {PackedUserOperation} from "lib/account-abstraction/contracts/interfaces/PackedUserOperation.sol";

contract EntryPoint {
    function handleOp(PackedUserOperation calldata userOp, bytes32 userOpHash) external returns (bytes memory) {
        IAccount iAccount = IAccount(userOp.sender);

        uint256 validationData = iAccount.validateUserOp(userOp, userOpHash, 0);
        require(validationData == 0, "validation failed");

        if (userOp.paymasterAndData.length >= 20) {
            address paymaster = address(uint160(bytes20(userOp.paymasterAndData[0:20])));
            (bytes memory context, uint256 paymasterValidation) =
                IPaymaster(paymaster).validatePaymasterUserOp(userOp, userOpHash, _estimateGasCost(userOp));
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
        // Decode accountGasLimits into callGasLimit and verificationGasLimit
        (uint128 callGasLimit, uint128 verificationGasLimit) =
            abi.decode(abi.encodePacked(userOp.accountGasLimits), (uint128, uint128));
        // Decode gasFees into maxFeePerGas and maxPriorityFeePerGas
        (uint128 maxFeePerGas,) = abi.decode(abi.encodePacked(userOp.gasFees), (uint128, uint128));

        // Calculate total gas cost
        uint256 totalGas = uint256(callGasLimit) + uint256(verificationGasLimit) + userOp.preVerificationGas;
        return totalGas * uint256(maxFeePerGas); // Use maxFeePerGas for estimation
    }

    function _execute(PackedUserOperation calldata userOp) internal returns (bool, bytes memory) {
        (address target, uint256 value, bytes memory data) = abi.decode(userOp.callData, (address, uint256, bytes));

        (bool success, bytes memory responseData) = ISmartAccount(userOp.sender).execute(target, value, data);
        require(success, "Execution failed");
        return (success, responseData);
    }

    receive() external payable {}
}
