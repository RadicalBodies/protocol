const Property = artifacts.require("./Property.sol");
const Market = artifacts.require("./Market.sol");

module.exports = function (deployer, network) {
  return deployer.then(async () => {
    await deployer.deploy(Property);
    const property = await Property.deployed();

    // interval = 3600 (1 hour)
    // taxRatePerInterval = 0.114155 (10% / year)
    // epsilon = 10000000000000000 (0.01 eth)
    // beneficiary = 0x0
    await deployer.deploy(Market, property.address, "3600", "114155", "10000000000000000", "0x0");

    // Transfer token issuance ownership
    await property.transferOwnership(Market.address);
  })
}
