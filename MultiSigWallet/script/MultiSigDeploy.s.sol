// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import {MultiSig} from "../src/MultiSig.sol";

contract MultiSigScript is Script {
    address private constant owner1 = 0xd8d32A7cBab0e4a36b8Ad5A6C1eE8c420771e674;
    address private constant owner2 = 0x98895e52d74ea14677b341A7FcA99b80486C8DDc;
    address private constant owner3 = 0xD8d32A7CbaB0e4A36b8Ad5A6c1Ee8c420771E635;

    function run() external returns (MultiSig) {
        address[] memory owners = new address[](3);
        owners[0] = owner1;
        owners[1] = owner2;
        owners[2] = owner3;
        uint256 required = 2;
        vm.startBroadcast();
        MultiSig multiSig = new MultiSig(owners, required);
        vm.stopBroadcast();
        return multiSig;
    }
}
