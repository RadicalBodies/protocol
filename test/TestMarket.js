const Property = artifacts.require("Property.sol");
const Market = artifacts.require("Market.sol");

contract('Market', function (accounts) {
    let property;
    let market;
    const beneficiary = "0x0000000000000000000000000000000000001234"

    beforeEach(async () => {
        property = await Property.new();
        market = await Market.new(property.address, "3600", "114155", "10000000000000000", beneficiary);
        property.transferOwnership(market.address);
    });

    it('basic market properties be correct', async () => {
        assert.equal((await market.interval()).toString(), "3600");
        assert.equal((await market.taxRatePerInterval()).toString(), "114155");
        assert.equal((await market.taxPrecision()).toString(), "1000000");
        assert.equal((await market.epsilon()).toString(), "10000000000000000");
    });

    it('should register a seller', async () => {
        await market.register("testURI");

        const tokens = await property.tokensByCreator(accounts[0]);
        // the initial ID is 0
        assert.equal(tokens[0], 0);

        assert.equal(tokens.length, 1);
        assert.equal(await property.tokenURI(tokens[0]), "testURI");
        assert.equal((await market.priceOf(tokens[0])).toString(), "0");
    });

    it('calculatePrice should work for 1 period', async () => {
        await market.register("testURI");

        const epsilon = await market.epsilon();
        const lastPrice = await market.priceOf(0);
        const reservePrice = lastPrice.add(epsilon);
        // 0.01 ETH
        assert.equal(reservePrice.toString(), "10000000000000000");

        const ret = await market.calculatePrice(0, 1, reservePrice);
        const periodStart = ret[0];
        const price = ret[1];
        const tax = ret[2];
        // 0.01 ETH
        assert.equal(price.toString(), "10000000000000000");
        // 0.0000114155 ETH
        assert.equal(tax.toString(), "11415500000000");
    });

    it('calculatePrice should work for multiple periods', async () => {
        await market.register("testURI");

        const epsilon = await market.epsilon();
        const lastPrice = await market.priceOf(0);
        const reservePrice = lastPrice.add(epsilon);
        // 0.01 ETH
        assert.equal(reservePrice.toString(), "10000000000000000");

        const ret = await market.calculatePrice(0, 5, reservePrice);
        const periodStart = ret[0];
        const price = ret[1];
        const tax = ret[2];
        // 0.01 ETH
        assert.equal(price.toString(), "10000000000000000");
        // 0.0000570775 ETH
        assert.equal(tax.toString(), "57077500000000");
    });

    it('should work for buy', async () => {
        await market.register("testURI");

        // 0.01 ETH
        const reservePrice = "10000000000000000";

        // reservePrice + tax: 0.0100114155 ETH
        const totalCost = "10011415500000000"

        await market.buy(0, 1, reservePrice, "adURI", { value: totalCost });

        // Price has bumped now.
        assert.equal((await market.priceOf(0)).toString(), reservePrice);
        // The property is owned.
        assert.equal(await property.variableMetadataURI(0), "adURI");
    });

    it('should work for withdrawAvailableFunds', async () => {
        await market.register("testURI");

        // 0.01 ETH
        const reservePrice = "10000000000000000";

        // reservePrice + tax: 0.0100114155 ETH
        const totalCost = "10011415500000000"

        await market.buy(0, 1, reservePrice, "adURI", { value: totalCost });

        // Price has bumped now.
        assert.equal((await market.priceOf(0)).toString(), reservePrice);
        // The property is owned.
        assert.equal(await property.variableMetadataURI(0), "adURI");

        const startBalance = web3.eth.getBalance(beneficiary);
        await market.withdrawAvailableFunds();
        const endBalance = web3.eth.getBalance(beneficiary);

        assert.equal(web3.eth.getBalance(market.address).toString(), "0");
        assert.equal(endBalance.sub(startBalance).toString(), "10011415500000000");
    });
});
