const {ethers} = require("hardhat");
require("dotenv").config({ path: ".env" });

async function main() {
  const CrowdFunding = await ethers.getContractFactory("CrowdFunding");
  this.crowdFunding = await CrowdFunding.deploy();
  console.log("Crowd Funding Address:", this.crowdFunding.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
