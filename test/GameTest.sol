// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {Game} from "../src/Game.sol";
import {PlayerS} from "../src/Players.sol";
import {Dice} from "../src/Dice.sol";
import {GeneralNFT} from "../src/NFT.sol";
import {EntryPoint} from "../src/account_abstraction/EntryPoint.sol";
import {Paymaster} from "../src/account_abstraction/Paymaster.sol";
import {Token} from "../src/account_abstraction/Token.sol";
import "lib/account-abstraction/contracts/interfaces/PackedUserOperation.sol";
import "../src/account_abstraction/interfaces/ISmartAccount.sol";
import "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";
contract GameTest is Test {
    Game public game;
    PlayerS public players;
    Dice private dice;
    GeneralNFT private generalNft;
    EntryPoint public entryPoint;
    Paymaster private paymaster;
    Token private token;

    uint256 private playerAKey = 1111;
    uint256 private playerBKey = 2222;
    uint256 private playerCKey = 3333;
    uint256 private playerDKey = 4444;

    address private playerA = vm.addr(playerAKey);
    address private playerB = vm.addr(playerBKey);
    address private playerC = vm.addr(playerCKey);
    address private playerD = vm.addr(playerDKey);

    function setUp() external {
        generalNft = new GeneralNFT("");
        players = new PlayerS();
        dice = new Dice();
        entryPoint = new EntryPoint();
        token = new Token(playerA);
        paymaster = new Paymaster(address(entryPoint), address(token));
    }

    function registerPlayer() private {
        players.registerPlayer(playerA, "player 1");
        players.registerPlayer(playerB, "player 2");
        players.registerPlayer(playerC, "player 3");
        players.registerPlayer(playerD, "player 4");
    }

    function createPackedUserOperation() internal returns (PackedUserOperation memory) {
        PackedUserOperation memory userOp;
        address playerSmartAccount = players.playerSmartAccount(playerA);
        userOp.sender = playerSmartAccount;
        userOp.nonce = ISmartAccount(playerSmartAccount).nonce();
        // for function setCount in the test contract
        
        userOp.callData = abi.encode(address(address(game)), 0, abi.encodeWithSignature("buyProperty(address)", playerSmartAccount));
        // userOp.callData = abi.encode(address(testContract), 0, abi.encodeWithSignature("incrementCount()"));
        
        userOp.accountGasLimits = bytes32(uint256(100000 << 128 | 100000));
        userOp.preVerificationGas = 21000;
        userOp.gasFees = bytes32(uint256(1e9 << 128 | 1e9));
        userOp.paymasterAndData = abi.encodePacked(address(paymaster), playerSmartAccount);

        // userOp.signature = bytes32(0);
        return userOp;
    }


    function generateUserSignature() internal returns (bytes memory) {
        PackedUserOperation memory userOp = createPackedUserOperation();
        bytes32 userOpHash = generateUserOpHash();
        bytes32 signedHash = MessageHashUtils.toEthSignedMessageHash(userOpHash);

        (uint8 v, bytes32 r , bytes32 s) = vm.sign(playerAKey, signedHash);

        return abi.encodePacked(r, s, v);
    }

     function generateUserOpHash() internal returns (bytes32) {
        PackedUserOperation memory userOp = createPackedUserOperation();
        bytes32 opHash = keccak256(abi.encode(
            userOp.sender,
            userOp.nonce,
            keccak256(userOp.initCode),
            keccak256(userOp.callData),
            userOp.accountGasLimits,
            userOp.preVerificationGas,
            userOp.gasFees,
            keccak256(userOp.paymasterAndData)
        ));
        
        bytes32 userOpHash = keccak256(abi.encode(opHash, block.chainid, address(entryPoint)));

        return userOpHash;
    }

    function testCreateAndPlay() external {
        game = new Game(address(generalNft), address(0), address(players), address(dice), false, 4);
        // token.collectToken(players.playerSmartAccount(playerA));
        registerPlayer();
        game.addPlayer(playerA);
        game.addPlayer(playerB);
        vm.expectRevert("Address already registered");
        game.addPlayer(playerA);
        game.addPlayer(playerC);
        game.addPlayer(playerD);

        token.collectToken(players.playerSmartAccount(playerA));

        game.startGame();
        token.approve(address(paymaster), 100 ether);
        game.play(playerA);

        PackedUserOperation memory userOp = createPackedUserOperation();
        bytes32 userOpHash = generateUserOpHash();
        bytes memory userSignature = generateUserSignature();

        userOp.signature = userSignature;
        //buy property
        entryPoint.handleOp(userOp, userOpHash);
        address newOwner =game.getPropertyOwner(6);

        assertEq(newOwner, playerA);                                                                                                                                                                                                
    }

}
