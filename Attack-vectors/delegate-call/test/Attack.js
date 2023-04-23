const { ethers } = require("hardhat");
const { expect } = require("chai");

describe("Attack", function () {
  it("Should override the owner of Good contract", async function () {
    const Helper = await ethers.getContractFactory("Helper");
    const helperContract = await Helper.deploy();
    await helperContract.deployed();
    console.log("Helper Contract address:", helperContract.address);

    const Good = await ethers.getContractFactory("Good");
    const goodContract = await Good.deploy(helperContract.address);
    await goodContract.deployed();
    console.log("Good Contract address:", goodContract.address);

    const Attack = await ethers.getContractFactory("Attack");
    const attackContract = await Attack.deploy(goodContract.address);
    await attackContract.deployed();
    console.log("Attack Contract address:", attackContract.address);

    let tx = await attackContract.attack();
    await tx.wait();

    expect(await goodContract.owner()).to.equal(attackContract.address)
  });
});
