//SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {IPaymaster} from "lib/account-abstraction/contracts/interfaces/IPaymaster.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {PackedUserOperation} from "lib/account-abstraction/contracts/interfaces/PackedUserOperation.sol";

contract Paymaster is IPaymaster {
    using SafeERC20 for IERC20;

    address public entryPoint;
    address public token;

    constructor(address _entryPoint, address _token) {
        entryPoint = _entryPoint;
        token = _token;
    }


    function validatePaymasterUserOp(
        PackedUserOperation calldata userOp,
        bytes32 userOpHash,
        uint256 maxCost
    ) external view returns (bytes memory context, uint256 validationData) {
        uint256 tokenCost = maxCost;
        uint256 senderBalance = IERC20(token).balanceOf(userOp.sender);
        uint256 paymasterSenderAllowance = IERC20(token).allowance(userOp.sender, address(this));
        require(senderBalance >= tokenCost, "Insufficient balance");
        require(paymasterSenderAllowance >= tokenCost, "Insufficient allowance");
        context = abi.encode(userOp.sender, tokenCost);
        return (context, 0);
    }

     function postOp(
        PostOpMode mode,
        bytes calldata context,
        uint256 actualGasCost,
        uint256 actualUserOpFeePerGas
    ) external {

        if (mode == PostOpMode.opReverted) {
            return;
        }

        (address sender, uint256 tokenCost) = abi.decode(context, (address,uint256));

        uint256 actualTokenCost = (actualGasCost * 1e18) / 1e18;
        IERC20(token).safeTransferFrom(sender, address(this), actualTokenCost);

        uint256 refund = address(this).balance >= actualGasCost ? actualGasCost : address(this).balance;
        if (refund > 0) {
            (bool success, ) = sender.call{value: refund}("");
            require(success, "Refund failed");
        }
    }

    function checkBalance() external view returns(uint256) {
        return address(this).balance;
    }

    receive() external payable { }  

}