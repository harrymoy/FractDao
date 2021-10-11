const { expect } = require("chai");
const { ethers } = require("hardhat");

/*
describe("Greeter", function() {
  it("Should return the new greeting once it's changed", async function() {
    const Greeter = await ethers.getContractFactory("Greeter");
    const greeter = await Greeter.deploy("Hello, world!");

    await greeter.deployed();
    expect(await greeter.greet()).to.equal("Hello, world!");

    await greeter.setGreeting("Hola, mundo!");
    expect(await greeter.greet()).to.equal("Hola, mundo!");
  });
});
*/

describe("FractDao", function() {
    let owner;
    let fdao;

    beforeEach(async () => {
      const [addr1] = await ethers.getSigners();
      const Settings = await hre.ethers.getContractFactory("Settings");
      const settings = await Settings.deploy();
      await settings.deployed();

      const FractDao = await hre.ethers.getContractFactory("FractDao");
      const fractdao = await FractDao.deploy(settings.address);
      await fractdao.deployed();
      fdao = fractdao;
      owner = addr1;
  });

  it("Should be able to mint tokens", async function() {
    await fdao.mintfdao(owner.getAddress(),1000);
    expect(await fdao.totalSupply()).to.equal(1000);
  });
});
