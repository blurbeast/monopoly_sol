//SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {ReentrancyGuard} from "../../lib/openzeppelin-contracts/contracts/utils/ReentrancyGuard.sol";
import {IAccount} from "lib/account-abstraction/contracts/interfaces/IAccount.sol";
import {IPaymaster} from "lib/account-abstraction/contracts/interfaces/IPaymaster.sol";
import {ISmartAccount} from "./interfaces/ISmartAccount.sol";
import {PackedUserOperation} from "lib/account-abstraction/contracts/interfaces/PackedUserOperation.sol";

contract EntryPoint is ReentrancyGuard {
    bytes32 private constant ACCOUNT_GAS_LIMITS = bytes32(uint256(150000 << 128) | uint256(100000));
    bytes32 private constant GAS_FEES = bytes32(uint256(20 gwei << 128) | uint256(1 gwei));
    uint256 private constant PRE_VERIFICATION_GAS = 21000;

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

    function getUserOpAndHash(address sender, uint256 nonce, bytes calldata callData, address paymaster)
        external
        view
        returns (PackedUserOperation memory userOp, bytes32 userOpHash)
    {
        // Reduce local variables by using constants directly
        bytes memory paymasterAndData = paymaster == address(0) ? bytes("") : abi.encodePacked(paymaster);

        userOp = PackedUserOperation({
            sender: sender,
            nonce: nonce,
            initCode: "",
            callData: callData,
            accountGasLimits: ACCOUNT_GAS_LIMITS,
            preVerificationGas: PRE_VERIFICATION_GAS,
            gasFees: GAS_FEES,
            paymasterAndData: paymasterAndData,
            signature: ""
        });

        bytes memory packed = abi.encode(
            userOp.sender,
            userOp.nonce,
            keccak256(userOp.initCode),
            keccak256(userOp.callData),
            userOp.accountGasLimits,
            userOp.preVerificationGas,
            userOp.gasFees,
            keccak256(userOp.paymasterAndData)
        );
        userOpHash = keccak256(abi.encodePacked(packed, address(this), block.chainid));

        return (userOp, userOpHash);
    }

    receive() external payable {}
}
