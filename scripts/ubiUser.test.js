const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("ubi users", function () {
  let users = [];
  let UbiFac = null;
  let ubi = null;
  const MONTH = 30*24*60*60;

  beforeEach(async function() {
    users = await ethers.getSigners();
    UbiFac = await ethers.getContractFactory("ubiUser");
    ubi = await UbiFac.deploy();
    await ubi.deployed();
  });
  afterEach(function() {
    users = null;
    UbiFac = null;
    ubi = null;
  });
  it("Test deploy contract", async function () {
    expect((await ubi.name())).to.equal("Ubi");
  });
  it("Test register", async function () {
    await ubi.register(users[1].address);
    expect((await ubi.balanceOf(users[1].address)).toNumber()).to.equal(0);
  });
  it("Test user not registered", async function () {
    try {
      await ubi.claim();
    } catch(e){
      expect(e.reason.indexOf("claim: user not registered")).to.not.equal(-1)
    }
  });
    it("Test user claim registered at the same month", async function () {
    await ubi.register(users[1].address);
    try {
      await ubi.connect(users[1]).claim();
    } catch(e){
      console.log(e.reason)
      expect(e.reason.indexOf("claim: not enough time has passed")).to.not.equal(-1)
    }
  });
    it("Test user claim one month", async function () {
    await ubi.register(users[1].address);
    await ethers.provider.send('evm_increaseTime', [MONTH])
    await ubi.connect(users[1]).claim();
    expect((await ubi.balanceOf(users[1].address)).toNumber()).to.equal(1729);
  });
  it("Test user claim two months", async function () {
    await ubi.register(users[1].address);
    await ethers.provider.send('evm_increaseTime', [MONTH*2])
    await ubi.connect(users[1]).claim();
    expect((await ubi.balanceOf(users[1].address)).toNumber()).to.equal(1729*2);
  });
});