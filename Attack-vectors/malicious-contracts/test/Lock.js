const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("malicious contract", function () {
  it("Should change the owner of Good contract", async function () {
    const Malicious = await ethers.getContractFactory("Malicious");
    const maliciousContract = await Malicious.deploy();
    await maliciousContract.deployed();
    console.log("Malicious Contract Address:", maliciousContract.address);

    const Good = await ethers.getContractFactory("Good");
    const goodContract = await Good.deploy(maliciousContract.address, {
      value: ethers.utils.parseEther("3"),
    });
    await goodContract.deployed();
    console.log("Good Contract Address:", goodContract.address);

    const [_, addr1] = await ethers.getSigners();
    let tx = await goodContract.connect(addr1).addUserToList();
    await tx.wait();

    const eligible = await goodContract.connect(addr1).isUserEligible();
    expect(eligible).to.equal(false);
  });
});
