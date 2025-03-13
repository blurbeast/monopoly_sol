// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "lib/account-abstraction/contracts/interfaces/PackedUserOperation.sol";
import "../src/account_abstraction/EntryPoint.sol";
import "../src/account_abstraction/SmartAccount.sol";
import "../src/account_abstraction/Paymaster.sol";
import "../src/account_abstraction/Test.sol";
import "../src/account_abstraction/Token.sol";
import "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

contract EntryPointTest is Test {
    EntryPoint private entryPoint;
    uint256 private constant privateKey = 0x12345678;
    address private immutable owner = vm.addr(privateKey);
    Paymaster private paymaster;
    SmartAccount private smartAccount;
    TestContract private testContract;
    Token public token;

    function setUp() external {
        entryPoint = new EntryPoint();
        testContract = new TestContract();
        smartAccount = new SmartAccount(owner, address(entryPoint), bytes(""));
        token = new Token(owner);
        paymaster = new Paymaster(address(entryPoint), address(token));
    }

    function createPackedUserOperation() internal returns (PackedUserOperation memory) {
        PackedUserOperation memory userOp;
        userOp.sender = address(smartAccount);
        userOp.nonce = smartAccount.nonce();
        // for function setCount in the test contract
        userOp.callData = abi.encode(address(testContract), 0, abi.encodeWithSignature("setCount(uint256)", 6));
        // userOp.callData = abi.encode(address(testContract), 0, abi.encodeWithSignature("incrementCount()"));

        userOp.accountGasLimits = bytes32(uint256(100000 << 128 | 100000));
        userOp.preVerificationGas = 21000;
        userOp.gasFees = bytes32(uint256(1e9 << 128 | 1e9));
        userOp.paymasterAndData = abi.encodePacked(address(paymaster), address(smartAccount));

        // userOp.signature = bytes32(0);
        return userOp;
    }

    function generateUserOpHash() internal returns (bytes32) {
        PackedUserOperation memory userOp = createPackedUserOperation();
        bytes32 opHash = keccak256(
            abi.encode(
                userOp.sender,
                userOp.nonce,
                keccak256(userOp.initCode),
                keccak256(userOp.callData),
                userOp.accountGasLimits,
                userOp.preVerificationGas,
                userOp.gasFees,
                keccak256(userOp.paymasterAndData)
            )
        );

        bytes32 userOpHash = keccak256(abi.encode(opHash, block.chainid, address(entryPoint)));

        return userOpHash;
    }

    function generateUserSignature() internal returns (bytes memory) {
        PackedUserOperation memory userOp = createPackedUserOperation();
        bytes32 userOpHash = generateUserOpHash();
        bytes32 signedHash = MessageHashUtils.toEthSignedMessageHash(userOpHash);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKey, signedHash);

        return abi.encodePacked(r, s, v);
    }

    function testEntryPoint() external {
        token.collectToken(address(smartAccount));
        vm.deal(address(paymaster), 100 ether);

        console.log("smart account balance in ether before minting ::: ", address(smartAccount).balance);
        console.log("owner balance in ether before minting ::: ", owner.balance);

        assertEq(address(paymaster).balance, 100 ether);
        assertEq(owner.balance, 0);
        assertEq(address(smartAccount).balance, 0 ether);
        assertEq(address(entryPoint).balance, 0 ether);

        console.log("entry point balance before the operation :::", address(entryPoint).balance);

        // vm.prank(owner);
        // smartAccount.mint(address(smartAccount), 1000 ether);
        console.log("smart account balance in ether after minting ::: ", address(smartAccount).balance);
        console.log("owner balance in ether after minting ::: ", owner.balance);

        // assertEq(smartAccount.balanceOf(address(smartAccount)), 1000 ether);

        vm.prank(address(smartAccount));
        token.approve(address(paymaster), 100 ether);

        assertEq(token.allowance(address(smartAccount), address(paymaster)), 100 ether);

        // now perform the action

        PackedUserOperation memory userOp = createPackedUserOperation();
        bytes32 userOpHash = generateUserOpHash();
        bytes memory userSignature = generateUserSignature();

        // userOp.userOpHash = userOpHash;
        userOp.signature = userSignature;

        console.log("smart account address test :::", address(smartAccount));
        entryPoint.handleOp(userOp, userOpHash);

        uint256 testContractCount = testContract.count();

        // for incrementCount function
        // assertEq(testContractCount, 1);

        // for setCOunt function
        assertEq(testContractCount, 6);

        assert(address(paymaster).balance < 100 ether);
        assertLe(address(paymaster).balance, 100 ether);
        assert(owner.balance == 0 ether);
        // assertEq(address(smartAccount).balance, 0 ether);
        // assertEq(address(entryPoint).balance, 0 ether);

        console.log("smart account balance in ether after operation ::: ", address(smartAccount).balance);
        console.log("owner balance in ether after operation ::: ", owner.balance);
        console.log("paymaster balance in ether after operation ::: ", address(paymaster).balance);
        console.log("entry point balance in ether after operation ::: ", address(entryPoint).balance);
    }
}
