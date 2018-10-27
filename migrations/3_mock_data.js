const Property = artifacts.require("./Property.sol");
const Market = artifacts.require("./Market.sol");

module.exports = function (deployer, network, accounts) {
  return deployer.then(async () => {
    const market = await Market.deployed();
    console.log(market.address);
    await market.register('5bd4898cb5e3838312c4c457', { from: accounts[0] });
    await market.register('5bd48a65b5e3838312c4c458', { from: accounts[1] });
    await market.register('5bd48ac1b5e3838312c4c459', { from: accounts[2] });
  })
}
