import { expect } from "chai";
import { ethers } from "hardhat";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import {
  SnapshotRestorer,
  takeSnapshot,
  time,
} from "@nomicfoundation/hardhat-network-helpers";
import { BummyCore, BummyCore__factory } from "../typechain-types";
import { BigNumber } from "ethers";
import { token } from "../typechain-types/@openzeppelin/contracts";

describe("BummyCore", async () => {
  let bummyCorefactory: BummyCore__factory;
  let bummyCore: BummyCore;
  let owner: SignerWithAddress;
  let addr1: SignerWithAddress;
  let addr2: SignerWithAddress;

  let totalSupply: BigNumber;
  let tokenId: BigNumber;

  let momid: BigNumber;
  let dadid: BigNumber;
  let snapshot: SnapshotRestorer;

  const provider = ethers.provider;
  beforeEach(async () => {
    [owner, addr1, addr2] = await ethers.getSigners();
    bummyCorefactory = await ethers.getContractFactory("BummyCore");
    bummyCore = await bummyCorefactory.deploy();
  });
  it("check name,symbol,...", async () => {
    expect(await bummyCore.name()).to.eq("BummyNFT");
    expect(await bummyCore.symbol()).to.eq("BV");
  });

  it("CEO,setCEO,setCOO", async () => {
    snapshot = await takeSnapshot();
    expect(await bummyCore.ceoAddress()).to.eq(owner.address);
    expect(await bummyCore.cooAddress()).to.eq(owner.address);
    await bummyCore.setCOO(addr1.address);
    expect(await bummyCore.cooAddress()).to.eq(addr1.address);
    await bummyCore.setCEO(addr2.address);
    expect(await bummyCore.ceoAddress()).to.eq(addr2.address);

    await snapshot.restore();
  });

  it("Create First Bummy", async () => {
    await bummyCore.unpause();
    snapshot = await takeSnapshot();
    await bummyCore.createFirstGen0Bummy();
    expect(await bummyCore.totalSupply()).to.eq(2);
    tokenId = await bummyCore.tokenOfOwnerByIndex(owner.address, 0);
    console.log("tokenId of owner:", tokenId.toString());

    await bummyCore.connect(addr1).createFirstGen0Bummy();
    tokenId = await bummyCore.tokenOfOwnerByIndex(addr1.address, 0);
    console.log("tokenId of owner:", tokenId.toString());
    expect(await bummyCore.totalSupply()).to.eq(3);

    await expect(
      bummyCore.connect(addr1).createFirstGen0Bummy()
    ).to.be.revertedWith("You already mint bummy");

    snapshot.restore;
  });

  it("Create 3 Crypto Bummy for promotion", async () => {
    await bummyCore.createPromoBummy(20, owner.address);
    totalSupply = await bummyCore.totalSupply();
    console.log("totalsupply:", totalSupply);
    expect(await bummyCore.tokenOfOwnerByIndex(owner.address, 0)).to.eq(1);

    await bummyCore.createPromoBummy(40, addr1.address);
    totalSupply = await bummyCore.totalSupply();
    console.log("totalsupply:", totalSupply.toString());
    expect(await bummyCore.tokenOfOwnerByIndex(addr1.address, 0)).to.eq(2);

    await expect(bummyCore.connect(addr2).createPromoBummy(60, addr2.address))
      .to.be.reverted;
    console.log(
      "totalsupply:",
      await (await bummyCore.totalSupply()).toString()
    );
  });
  it("Transfer Bummy to other", async () => {
    snapshot = await takeSnapshot();
    await bummyCore.createPromoBummy(20, owner.address);
    let numOfBummy = await bummyCore.balanceOf(owner.address);
    let numOfBummy1 = await bummyCore.balanceOf(addr1.address);
    console.log("num of Bummy:", numOfBummy, numOfBummy1);
    await bummyCore.transferFrom(owner.address, addr1.address, 1);

    numOfBummy = await bummyCore.balanceOf(owner.address);
    numOfBummy1 = await bummyCore.balanceOf(addr1.address);
    console.log("num of Bummy:", numOfBummy.toString(), numOfBummy1.toString());

    await snapshot.restore();
  });
  it("Cheering two bummy & Invite new Bummy", async () => {
    await bummyCore.unpause();
    await bummyCore.connect(owner).createFirstGen0Bummy();
    await bummyCore.connect(addr1).createFirstGen0Bummy();

    momid = await bummyCore.tokenOfOwnerByIndex(owner.address, 0);
    dadid = await bummyCore.tokenOfOwnerByIndex(addr1.address, 0);
    console.log("momid:", momid.toString(), "dadid:", dadid.toString());
    //* owner에게 dadid의 소유자인 addr1가 승인
    await bummyCore.connect(addr1).approveCheering(owner.address, dadid);
    await bummyCore.cheerWith(momid, dadid);
    console.log(await bummyCore.getBummy(momid));
    await time.increase(3600);
    await bummyCore.inviteFriend(momid);
    await bummyCore.tokenOfOwnerByIndex(owner.address, 1);
  });
});
