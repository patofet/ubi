
const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("ubi", function () {
  let users = [];
  let UbiFac = null;
  let ubi = null;
  const MONTH = 1000 * 60 * 60 * 24 * 60

  beforeEach(async function() {
    users = await ethers.getSigners();
    UbiFac = await ethers.getContractFactory("ubi");
    ubi = await UbiFac.deploy();
    await ubi.deployed();
  });
  afterEach(function() {
    users = null;
    UbiFac = null;
    ubi = null;
  });
  it("Test deploy", async function () {
    expect((await ubi.name())).to.equal("Ubi");
  });
  it("Test claim", async function () {
    await ubi.setUserAndClaim("10");
    expect((await ubi.balanceOf(users[0].address)).toNumber()).to.equal(17290);
  });
  it("Test claim two times in the same month", async function () {
    await ubi.setUserAndClaim("10");
    expect((await ubi.balanceOf(users[0].address)).toNumber()).to.equal(17290);
    try {
      await ubi.setUserAndClaim("10");
    } catch(e){
      expect(e.reason.indexOf("claim: not enough time has passed")).to.not.equal(-1)
    }
  });
  it("Test claim two times in the next month", async function () {
    await ubi.setUserAndClaim("10");
    expect((await ubi.balanceOf(users[0].address)).toNumber()).to.equal(17290);
    await ethers.provider.send('evm_increaseTime', [MONTH])
    await ubi.setUserAndClaim("10");
    expect((await ubi.balanceOf(users[0].address)).toNumber()).to.equal(17290 * 2);
  });
});