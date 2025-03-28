// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import {GeneralNFT} from "../src/NFT.sol";
import {Script, console} from "forge-std/Script.sol";

contract NFTContract is Script {
    GeneralNFT public generalNft;

    function run() external {
        uint256 privateK = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(privateK);

        generalNft = new GeneralNFT("oloba");

        console.log("contract address of bank is ::: ", address(generalNft));

        vm.stopBroadcast();
    }

    // 0x98D8643215747e8B81e1b90424b644C3FCFf75ea test Nft contract address deployed on sepolia testnet
}
