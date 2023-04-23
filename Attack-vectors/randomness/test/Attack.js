const { ethers, waffle } = require("hardhat");
const { expect } = require("chai");
const { BigNumber, utils } = require("ethers");

describe("Attack function", function () {
  it("Should guess the same number", async function () {
    const Game = await ethers.getContractFactory("Game");
    const gameContract = await Game.deploy({ value: utils.parseEther("0.1") });
    await gameContract.deployed();
    console.log("Game Contract Address:", gameContract.address);

    const Attack = await ethers.getContractFactory("Attack");
    const attackContract = await Attack.deploy(gameContract.address);
    await attackContract.deployed();
    console.log("Attack Contract Address:", attackContract.address);

    const tx = await attackContract.attack();
    await tx.wait();

    const balance = await gameContract.getBalance();
    expect(balance).to.equal(BigNumber.from("0"));
  });
});
