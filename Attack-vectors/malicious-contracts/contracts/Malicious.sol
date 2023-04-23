// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract Malicious{
    address owner;
    mapping(address => bool) userEligible;

    constructor(){
        owner = msg.sender;
    }

    function isUserEligible(address user) public view returns(bool){
        if (user == owner){
            return true;
        }
        return false;
    }

    function setUserEligible(address user) public{
        userEligible[user] = true;
    }    

    fallback() external{}
}