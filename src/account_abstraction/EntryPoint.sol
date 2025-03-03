//SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;


import "lib/account-abstraction/contracts/interfaces/IAccount.sol";
import "lib/account-abstraction/contracts/interfaces/IPaymaster.sol";
import {ISmartAccount} from "./interfaces/ISmartAccount.sol";

contract EntryPoint {

    function handleUserOp(PackedUserOperation calldata userOp, bytes32 userOpHash) external {
        IAccount iAccount = IAccount(userOp.sender);

        uint256 validationData = iAccount.validateUserOp(userOp, userOpHash, 0);
        require(validationData == 0, "validation failed");

        if(userOp.paymasterAndData.length >= 20) {
            address paymaster = address(uint160(bytes20(userOp.paymasterAndData[0:20])));
            (bytes memory context, uint256 paymasterValidation) = IPaymaster(paymaster).validatePaymasterUserOp(
                userOp,
                userOpHash,
                gasleft()
            );
            require(paymasterValidation == 0, "Paymaster validation failed");

            _execute(userOp);
            IPaymaster(paymaster).postOp(IPaymaster.PostOpMode.opSucceeded, context, gasleft() ,0);
        }
        else {
            _execute(userOp);
        }
    }

    function _execute(PackedUserOperation calldata userOp) internal returns (bool , bytes memory) {
        (address target, uint256 value, bytes memory data) = abi.decode(userOp.callData, (address, uint256, bytes));

        (bool success, bytes memory responseData) = ISmartAccount(userOp.sender).execute(target, value, data);
        require(success, "Execution failed");
        return (success, responseData);
    } 
    function recieve() external payable {}
}