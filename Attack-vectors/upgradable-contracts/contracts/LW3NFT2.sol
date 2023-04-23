// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;
import "./LW3NFT.sol";


contract LW3NFT2 is LW3NFT{
    function test() public pure returns(string memory){
        return("upgraded");
    }

}