const { ethers } = require("hardhat");
const { expect } = require("chai");

describe("Denial of Service", function () {
  it("After being declared the winner, Attack.sol should not let anyone become a new winner", async function () {
    const Good = await ethers.getContractFactory("Good");
    const good = await Good.deploy();
    await good.deployed();
    console.log("Good contract address:", good.address);

    const Attack = await ethers.getContractFactory("Attack");
    const attack = await Attack.deploy(good.address);
    await attack.deployed();
    console.log("Attack contract address:", attack.address);

    const [_, addr1, addr2] = await ethers.getSigners();
    let tx = await good.connect(addr1).setCurrentAuctionPrice({
      value: ethers.utils.parseEther("1"),
    });
    await tx.wait();

    tx = await attack.attack({
      value: ethers.utils.parseEther("3"),
    });
    await tx.wait();

    tx = await good.connect(addr2).setCurrentAuctionPrice({
      value: ethers.utils.parseEther("4"),
    });
    await tx.wait();

    expect(await good.currentWinner()).to.equal(attack.address);
  });
});
