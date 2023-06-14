const { expect } = require("chai");
const { ethers } = require("ethers");


describe("TokenSwap", function () {
  let tokenSwap;
  let uniswapRouter;
  let pairAddress;

  const USDT_ADDRESS = "0xdAC17F958D2ee523a2206206994597C13D831ec7"; 
  const GUSD_ADDRESS = "0x056Fd409E1d7A124BD7017459dFEa2F387b6d5Cd"; 
  const WETH_ADDRESS = "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2"; 
  const DAI_ADDRESS = "0x6B175474E89094C44Da98b954EedeAC495271d0F"; 


  const BUY_AMOUNT = ethers.utils.parseUnits("10", 18);


  let impersonatedSigner;

  before(async function () {
    const TokenSwap = await ethers.getContractFactory("TokenSwap");
    tokenSwap = await TokenSwap.deploy();
    await tokenSwap.deployed();

    
    uniswapRouter = await ethers.getContractAt(
      "IUniswapV2Router",
      "0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D"
    );

    
    await uniswapRouter.createPair(USDT_ADDRESS, GUSD_ADDRESS);
    pairAddress = await uniswapRouter.getPair(USDT_ADDRESS, GUSD_ADDRESS);

    
    impersonatedSigner = await ethers.provider.getSigner(
      "0x7d2768dE32b0b80b7a3454c06BdAc94A69DDc7A9"
    );
  });

  it("should swap USDT for GUSD", async function () {
    const initialGUSDBalance = await ethers.provider.getBalance(GUSD_ADDRESS);
    const initialUSDTBalance = await ethers.provider.getBalance(USDT_ADDRESS);

    // Имперсонация кошелька
    await impersonatedSigner.sendTransaction({
      to: tokenSwap.address,
      value: ethers.utils.parseEther("1"),
    });

    
    const approveTx = await impersonatedSigner.sendTransaction({
      to: USDT_ADDRESS,
      value: ethers.utils.parseEther("0"),
      data: tokenSwap.interface.encodeFunctionData("transfer", [
        tokenSwap.address,
        BUY_AMOUNT,
      ]),
    });
    await approveTx.wait();

    
    const tx = await tokenSwap
      .connect(impersonatedSigner)
      .swapTokens(pairAddress, GUSD_ADDRESS, BUY_AMOUNT);
    const receipt = await tx.wait();

    
    const gasUsed = receipt.gasUsed;
    const gasPrice = tx.gasPrice;
    const gasCost = gasUsed.mul(gasPrice);

    const finalGUSDBalance = await ethers.provider.getBalance(GUSD_ADDRESS);
    expect(finalGUSDBalance.sub(initialGUSDBalance)).to.equal(BUY_AMOUNT);

    const finalUSDTBalance = await ethers.provider.getBalance(USDT_ADDRESS);
    expect(initialUSDTBalance.sub(finalUSDTBalance)).to.be.closeTo(
      BUY_AMOUNT.add(gasCost),
      1000
    ); // Допустимая погрешность 1000 wei

    console.log("Gas used:", gasUsed.toString());
  });

  it("should swap WETH for DAI", async function () {
    const initialDAIBalance = await ethers.provider.getBalance(DAI_ADDRESS);
    const initialWETHBalance = await ethers.provider.getBalance(WETH_ADDRESS);

    await impersonatedSigner.sendTransaction({
      to: tokenSwap.address,
      value: ethers.utils.parseEther("1"),
    });

    const approveTx = await impersonatedSigner.sendTransaction({
      to: WETH_ADDRESS,
      value: ethers.utils.parseEther("0"),
      data: tokenSwap.interface.encodeFunctionData("transfer", [
        tokenSwap.address,
        BUY_AMOUNT,
      ]),
    });
    await approveTx.wait();

    const tx = await tokenSwap
      .connect(impersonatedSigner)
      .swapTokens(pairAddress, DAI_ADDRESS, BUY_AMOUNT);
    const receipt = await tx.wait();

    const gasUsed = receipt.gasUsed;
    const gasPrice = tx.gasPrice;
    const gasCost = gasUsed.mul(gasPrice);

    const finalDAIBalance = await ethers.provider.getBalance(DAI_ADDRESS);
    expect(finalDAIBalance.sub(initialDAIBalance)).to.equal(BUY_AMOUNT);

    const finalWETHBalance = await ethers.provider.getBalance(WETH_ADDRESS);
    expect(initialWETHBalance.sub(finalWETHBalance)).to.be.closeTo(
      BUY_AMOUNT.add(gasCost),
      1000
    ); // Допустимая погрешность 1000 wei

    console.log("Gas used:", gasUsed.toString());
  });

  it("should withdraw tokens", async function () {
    const withdrawAmount = ethers.utils.parseUnits("5", 18); // Количество токенов для вывода

    
    const tx = await tokenSwap.withdrawTokens(GUSD_ADDRESS, withdrawAmount);
    const receipt = await tx.wait();

    const gasUsed = receipt.gasUsed;
    const gasPrice = tx.gasPrice;
    const gasCost = gasUsed.mul(gasPrice);

    const finalGUSDBalance = await ethers.provider.getBalance(GUSD_ADDRESS);
    expect(finalGUSDBalance.sub(initialGUSDBalance)).to.equal(withdrawAmount);

    const contractBalance = await ethers.provider.getBalance(tokenSwap.address);
    expect(contractBalance).to.equal(0);

    const finalContractBalance = await ethers.provider.getBalance(
      tokenSwap.address
    );
    expect(finalContractBalance).to.be.closeTo(gasCost, 1000); // Допустимая погрешность 1000 wei

    console.log("Gas used:", gasUsed.toString());
  });
});
