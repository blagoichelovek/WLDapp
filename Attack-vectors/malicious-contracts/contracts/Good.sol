// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "./Helper.sol";

contract Good{
    Helper helper;
    constructor(address _helper) payable {
        helper = Helper(_helper);
    }

    function isUserEligible() public view returns(bool){
        return helper.isUserEligible(msg.sender);
    }

    function addUserToList() public{
        helper.setUserEligible(msg.sender);
    }

    fallback() external{}


}