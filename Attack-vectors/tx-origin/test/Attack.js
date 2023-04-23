const { expect } = require("chai")
const { ethers } = require("hardhat")

describe("tx.origin", function () {
  it("Attack.sol should be able to change owner of Good.sol", async function () {
    const [_, addr1] = await ethers.getSigners()
    const Good = await ethers.getContractFactory("Good")
    const good = await Good.connect(addr1).deploy()
    await good.deployed()
    console.log("Good contract address:", good.address)

    const Attack = await ethers.getContractFactory("Attack")
    const attack = await Attack.deploy(good.address)
    await attack.deployed()
    console.log("Attack contract address:", attack.address)

    let tx = await attack.connect(addr1).attack()
    expect(await good.owner()).to.equal(attack.address)
  })
})