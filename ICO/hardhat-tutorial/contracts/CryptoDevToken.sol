//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./ICryptoDevs.sol";


contract CryptoDevToken is ERC20, Ownable{
    ICryptoDevs CryptoDevsNFT;

    uint256 public constant tokenPrice = 0.001 ether;

    uint256 public constant tokensPerNFT = 10 * 10**18;

    uint256 public constant maxTotalSupply = 10000 * 10**18;

    mapping (uint256 => bool) public tokenIdsClaimed;



    constructor(address _cryptoDevsContract) ERC20("Crypto Devs Token", "CD") {
        CryptoDevsNFT = ICryptoDevs(_cryptoDevsContract);
    }

    function claim() public {
        address sender = msg.sender;
        uint256 balance = CryptoDevsNFT.balanceOf(sender);
        require(balance > 0, "You don't own Crypto Devs NFT");
        uint256 amount = 0;

        for (uint256 i = 0; i < balance; i++) {
            uint256 tokenId = CryptoDevsNFT.tokenOfOwnerByIndex(sender, i);

            if(!tokenIdsClaimed[tokenId]){
            amount += 1;
            tokenIdsClaimed[tokenId] = true;
            }
        }
        

        require(amount > 0, "You have already claimed all tokens");
        _mint(msg.sender, amount * tokensPerNFT);
    }

    function mint(uint256 amount) public payable{
        uint256 _requiredAmount = tokenPrice * amount;
        require(msg.value >= _requiredAmount, "Ether sent is incorrect");
        uint256 amountWithDecimals = amount * 10**18;
        require(
           (totalSupply() + amountWithDecimals) <= maxTotalSupply, "Exceeds max token supply"
        );

        _mint(msg.sender, amountWithDecimals);
    }


    function withdraw() public onlyOwner{
        uint256 amount = address(this).balance;
        require(amount > 0, "Nothing to withdraw, contract is empty");
        address _owner = owner();
        (bool sent, ) = _owner.call{value: amount}("");
        require(sent, "Failed to sent ether");
    }

    receive() external payable{

    }

    fallback() external payable{

    }

    

    
}