const hre = require("hardhat");
const { expect } = require("chai");

async function main() {
	const [signer1, signer2] = await ethers.getSigners()

  // deploy
  // -_-_-_-_-_-_ deploy our 3 contracts -_-_-_-_-_-_
	const Token = await ethers.getContractFactory('YourToken', signer1)
  const token = await Token.deploy()
  await token.deployed()

  //console.log(signer1.address)
  console.log("Address of ERC20 contract: " + token.address)

  const NFT = await ethers.getContractFactory('NFT', signer2)
  const nft = await NFT.deploy(token.address)
  await nft.deployed()

  //console.log(signer2.address)
  console.log("Address of NFT contract: " + nft.address)

  const StakingNFT = await ethers.getContractFactory('StakingNFT', signer2)
  const stake = await StakingNFT.deploy(token.address, nft.address)
  await stake.deployed()

  //console.log(signer2.address)
  console.log("Address of staking contract: " + stake.address)

  const ownerBalance = await token.balanceOf(signer1.address);
  console.log("Owner's balance = " + ownerBalance + "\n")

  // test_1
  // -_-_-_-_-_-_ transfer 50 tokens signer1 owner to signer2 -_-_-_-_-_-_
  await token.connect(signer1).transfer(signer2.address, 1000)

  const signer_1_Balance = await token.balanceOf(signer1.address)
  console.log("First signer balance = " + signer_1_Balance + "\n")

  const signer_2_Balance = await token.balanceOf(signer2.address);
  console.log("Second signer balance = " + signer_2_Balance + "\n")

  // test_2
  // -_-_-_-_-_-_ signer1 buys 100 NFTs -_-_-_-_-_-_
  await token.connect(signer1).approve(nft.address, 1000)

  const temp = await token.allowance(signer1.address, nft.address)
  console.log("1 allowed to 2 to spend " + temp + " tokens\n")

  for(var i = 0; i < 5; i++) {
    await nft.connect(signer1).buyTokens(20)
  }

  const signer_2_Balance_new = await token.balanceOf(signer2.address);
  console.log("Second signer balance after nft was bought = " + signer_2_Balance_new + "\n")

  // test_3
  // -_-_-_-_-_-_ signer2 stakes his 100 NFTs -_-_-_-_-_-_
  await token.connect(signer2).approve(stake.address, 1000)

  await stake.connect(signer2).makeRewardPool(1000)

  const award_pool = await stake.connect(signer2).getRewardPool()
  console.log("RewardPool equals " + award_pool + " tokens\n")

  // await nft.connect(signer1).setApprovalForAll(stake.address, true) // instead of approve() for only 1 NFT!!!
  
  for(var i = 1; i <= 10; i++) {
    const isOwner = await nft.connect(signer1).ownerOf(i)

    if(isOwner == signer1.address) {
      await nft.connect(signer1).approve(stake.address, i)
      await stake.connect(signer1).stake(i)
      console.log("Owner of id(" + i + ") is " + await nft.ownerOf(i))
    }
  }

  var i = 0;
  while(i < 10000000000) {
    i++;
  }

  console.log("Owner's old balance = " + await token.balanceOf(signer1.address) + "\n")
  for(var i = 1; i <= 10; i++) {
    await stake.connect(signer1).unstake(i)  
  }

  console.log("Owner's new balance = " + await token.balanceOf(signer1.address) + "\n")
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
