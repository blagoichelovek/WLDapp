const { ethers } = require("hardhat");
require("dotenv").config({ path: ".env" });
const { FEE, LINK_TOKEN, VRF_COORDINATOR, KEY_HASH } = require("../constants");

async function main() {
  const randomWinnerGame = await ethers.getContractFactory("RandomWinnerGame");
  const deployedRandomWinnerGame = await randomWinnerGame.deploy(
    VRF_COORDINATOR,
    LINK_TOKEN,
    KEY_HASH,
    FEE,
  );
  await deployedRandomWinnerGame.deployed();
  console.log(
    "Randow Winner Game Contract Address:",
    deployedRandomWinnerGame.address
  );

  console.log("Sleeping...");
  await sleep(30000);

  await hre.run("verify:verify", {
    address: deployedRandomWinnerGame.address,
    constructorArguments: [VRF_COORDINATOR, LINK_TOKEN, KEY_HASH, FEE],
  });

  function sleep(ms) {
    return new Promise((resolve) => setTimeout(resolve, ms));
  }
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
