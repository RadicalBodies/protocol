const Property = artifacts.require("Property.sol");

contract('Property', function (accounts) {

    let property;

    beforeEach(async () => {
        property = await Property.new();
    });

    it('should allow minting of new properties', async () => {
        await property.mintWithTokenURI(accounts[0], 0, "foo");

        assert.equal(await property.creatorOfToken(0), accounts[0]);
        assert.equal((await property.tokensByCreator(accounts[0]))[0], 0);
    });

    it('should allow burning of properties', async () => {
        await property.mintWithTokenURI(accounts[0], 0, "foo");
        await property.mintWithTokenURI(accounts[0], 1, "foo");

        assert.equal(await property.creatorOfToken(1), accounts[0]);

        await property.burn(0);

        assert.equal((await property.tokensByCreator(accounts[0]))[0], 1);
    });

    it('should be possible for the owner to move tokens', async () => {
        await property.mintWithTokenURI(accounts[0], 0, "foo");
        assert.equal(await property.ownerOf(0), accounts[0]);

        await property.move(0, accounts[1]);
        assert.equal(await property.ownerOf(0), accounts[1]);
    });

    it('should be possible to replace variable metadata', async () => {
        await property.mintWithTokenURI(accounts[0], 0, "foo");
        assert.equal(await property.ownerOf(0), accounts[0]);

        assert.equal(await property.variableMetadataURI(0), "");

        await property.replaceVariableMetadataURI(0, "test");
        assert.equal(await property.variableMetadataURI(0), "test");

        await property.replaceVariableMetadataURI(0, "hello");
        assert.equal(await property.variableMetadataURI(0), "hello");
    });
});
