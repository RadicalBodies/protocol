const Property = artifacts.require("Property.sol");
const Market = artifacts.require("Market.sol");

contract('Market', function (accounts) {
    let property;
    let market;

    beforeEach(async () => {
        property = await Property.new();
        market = await Market.new(property.address, "3600", "114155", "10000000000000000", "0x0");
        property.transferOwnership(market.address);
    });

    it('should register a seller', async () => {
        await market.register("testURI");

        const tokens = await property.tokensByCreator(accounts[0]);

        assert.equal(tokens.length, 1);
        assert.equal(await property.tokenURI(tokens[0]), "testURI");
        assert.equal((await market.priceOf(tokens[0])).toString(), "0");
    });
});
