const Property = artifacts.require("Property.sol");

contract('Property', function (accounts) {

    let property;

    beforeEach(async () => {
        property = await Property.new();
    });

    it('should allow minting of new properties', async () => {
        await property.mintWithTokenUri(accounts[0], 0, "foo");

        assert.equal(await property.creatorOfToken(0), accounts[0]);
        assert.equal((await property.tokensByCreator(accounts[0]))[0], 0);
    });

    it('should allow burning of properties', async () => {
        await property.mintWithTokenUri(accounts[0], 0, "foo");
        await property.mintWithTokenUri(accounts[0], 1, "foo");

        assert.equal(await property.creatorOfToken(1), accounts[0]);

        await property.burn(0);

        assert.equal((await property.tokensByCreator(accounts[0]))[0], 1);
    })

});