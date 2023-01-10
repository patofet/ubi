
const { expect } = require("chai");
const { ethers } = require("hardhat");
const web3 = require("web3")

describe("ubi", function () {
  const MONTH = 1000 * 60 * 60 * 24 * 60
  it("Test deploy", async function () {
    const Ubi = await ethers.getContractFactory("ubi");
    const ubi = await Ubi.deploy();
    await ubi.deployed();
    expect((await ubi.name())).to.equal("Ubi");
  });
  it("Test claim", async function () {
    const [owner] = await ethers.getSigners();
    const Ubi = await ethers.getContractFactory("ubi");
    const ubi = await Ubi.deploy();
    await ubi.deployed();
    await ubi.setUserAndClaim("10");
    expect((await ubi.balanceOf(owner.address)).toNumber()).to.equal(17290);
  });
  it("Test claim two times", async function () {
    const [owner] = await ethers.getSigners();
    const Ubi = await ethers.getContractFactory("ubi");
    const ubi = await Ubi.deploy();
    await ubi.deployed();
    await ubi.setUserAndClaim("10");
    expect((await ubi.balanceOf(owner.address)).toNumber()).to.equal(17290);
    
    await ethers.provider.send('evm_increaseTime', [MONTH])

    await ubi.setUserAndClaim("10");
  });
});