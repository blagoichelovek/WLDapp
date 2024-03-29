const { ethers } = require("hardhat");
const { expect } = require("chai");
const hre = require("hardhat");

describe("Proxy Pattern", function () {
  it("Should deploy an upgradable ERC721", async function () {
    const LW3NFT = await ethers.getContractFactory("LW3NFT");
    const LW3NFT2 = await ethers.getContractFactory("LW3NFT2");

    let proxyContract = await hre.upgrades.deployProxy(LW3NFT, {
      kind: "uups",
    });

    const [owner] = await ethers.getSigners();
    const ownerOfToken1 = await proxyContract.ownerOf(1);

    expect(ownerOfToken1).to.equal(owner.address);

    proxyContract = await hre.upgrades.upgradeProxy(proxyContract, LW3NFT2);

    expect(await proxyContract.test()).to.equal("upgraded");
  });
});
