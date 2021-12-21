const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("AfroApes", function () {
  it("Should return true if address is added to whitelist", async function () {
    const AfroApes = await ethers.getContractFactory("AfroApes");
    const afroapes = await AfroApes.deploy();
    await afroapes.deployed();
    // console.log(await afroapes.getMyAddress());
    expect(await afroapes.getMyAddress()).to.equal(true);
  });

  it("Should return false. Address is not added to whitelist", async function () {
    const AfroApes = await ethers.getContractFactory("AfroApes");
    const afroapes = await AfroApes.deploy();
    await afroapes.deployed();
    expect(
      await afroapes.verifyAddressIsOnWhiteList(
        "0x5B38Da6a701c568545dCfcB03FcB875f56beddC4"
      )
    ).to.equal(false);
  });
  it("Should add an address to whitelist", async function () {
    const AfroApes = await ethers.getContractFactory("AfroApes");
    const afroapes = await AfroApes.deploy();
    await afroapes.deployed();

    const addWhiteListAddress = await afroapes.addWhiteListAddress(
      ethers.utils.getAddress("0x5B38Da6a701c568545dCfcB03FcB875f56beddC4")
    );

    // wait until the transaction is mined
    await addWhiteListAddress.wait();

    expect(
      await afroapes.verifyAddressIsOnWhiteList(
        "0x5B38Da6a701c568545dCfcB03FcB875f56beddC4"
      )
    ).to.equal(true);
  });
});
