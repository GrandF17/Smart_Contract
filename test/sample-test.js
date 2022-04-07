const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Deploy", function () {
  it("Should deploy 3 contracts", async function () {
    const [signer1, signer2] = await ethers.getSigners()

    const Token = await ethers.getContractFactory('YourToken', signer1)
    const token = await Token.deploy()
    await token.deployed()

    const NFT = await ethers.getContractFactory('NFT', signer2)
    const nft = await NFT.deploy(token.address)
    await nft.deployed()

    const StakingNFT = await ethers.getContractFactory('StakingNFT', signer2)
    const stake = await StakingNFT.deploy(token.address, nft.address)
    await stake.deployed()

    expect(await token.balanceOf(signer1.address)).to.equal(10000);
  });
});

describe("YourToken", function () {
  it("Should tranfer from signer1 to signer2 1000 ERC20", async function () {
    const [signer1, signer2] = await ethers.getSigners()

    const Token = await ethers.getContractFactory('YourToken', signer1)
    const token = await Token.deploy()
    await token.deployed()

    await token.connect(signer1).transfer(signer2.address, 1000)
    expect(await token.balanceOf(signer2.address)).to.equal(1000);
  });
});

describe("NFT buying", function () {
  it("Signer1 buys 100 NFTs from signer2 (who deployed NFT contract)", async function () {
    const [signer1, signer2] = await ethers.getSigners()

    const Token = await ethers.getContractFactory('YourToken', signer1)
    const token = await Token.deploy()
    await token.deployed()

    const NFT = await ethers.getContractFactory('NFT', signer2)
    const nft = await NFT.deploy(token.address)
    await nft.deployed()

    await token.connect(signer1).approve(nft.address, 1000)

    for(var i = 0; i < 5; i++) {
      await nft.connect(signer1).buyTokens(20)
    }

    expect(await nft.balanceOf(signer1.address)).to.equal(100);
  });
});