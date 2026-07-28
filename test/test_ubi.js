const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("UBI & UBIMarketplace Ecosystem", function () {
    let UBI, ubiToken;
    let UBIMarketplace, marketplace;
    let owner, addr1, addr2;

    beforeEach(async function () {
        [owner, addr1, addr2] = await ethers.getSigners();

        // 1. Deploy UBI Token
        UBI = await ethers.getContractFactory("UBI");
        ubiToken = await UBI.deploy();
        await ubiToken.deployed();

        // 2. Deploy UBIMarketplace
        UBIMarketplace = await ethers.getContractFactory("UBIMarketplace");
        marketplace = await UBIMarketplace.deploy(ubiToken.address);
        await marketplace.deployed();
    });

    describe("UBI Token Deployment", function () {
        it("Should deploy with correct name and symbol", async function () {
            expect(await ubiToken.name()).to.equal("UBI");
            expect(await ubiToken.symbol()).to.equal("UBI");
        });
    });

    describe("Marketplace Configuration & Permissions", function () {
        it("Should set the deployer as the initial owner", async function () {
            expect(await marketplace.owner()).to.equal(owner.address);
        });

        it("Should allow owner to toggle creator permissions", async function () {
            expect(await marketplace.isAllowedToCreate(addr1.address)).to.equal(false);
            
            await marketplace.toggleCreators([addr1.address]);
            expect(await marketplace.isAllowedToCreate(addr1.address)).to.equal(true);

            await marketplace.toggleCreators([addr1.address]);
            expect(await marketplace.isAllowedToCreate(addr1.address)).to.equal(false);
        });

        it("Should revert if non-allowed address tries to create a collection", async function () {
            let reverted = false;
            try {
                await marketplace.connect(addr1).createCollection("Test NFT", "TNFT", "https://api.test/", 1000);
            } catch (error) {
                reverted = true;
                expect(error.message).to.include("createCollection: the address is not allowed to create collections");
            }
            expect(reverted).to.equal(true);
        });
    });
});
