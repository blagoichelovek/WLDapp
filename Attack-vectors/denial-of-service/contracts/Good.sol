// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract Good {

    address public currentWinner;
    uint public currentAuctionPrice;

    constructor() {
        currentWinner = msg.sender;
    }

    function setCurrentAuctionPrice() public payable{
        require(msg.value > currentAuctionPrice, "Need to pay more than current auction price");
        (bool sent, ) = currentWinner.call{value: currentAuctionPrice }("");

        if(sent){
            currentAuctionPrice = msg.value;
            currentWinner = msg.sender;
        }
    }
}
