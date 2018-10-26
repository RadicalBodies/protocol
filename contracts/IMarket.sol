// @title Radical Bodies market.
interface IMarket {
    // The tax rate in basis points, 0 to 1000000.
    function taxRate() external view returns (uint256);

    // The minimum bid/increase. (in ETH)
    function epsilon() external view returns (uint256);

    // The beneficiary receiving all the funds.
    function beneficiary() external view returns (address);

    // The beneficiary can retrieve already released funds via this.
    function withdrawAvailableFunds() external payable;

    // Creates a new token. ERC721 + ERC721Metadata
    // @param metadataURI IPFS URL for all the user details
    // @returns the tokenId
    //
    // Uses msg.sender as token owner. Calls mintWithTokenURI(msg.sender, <tokenId>, metadataURI);
    //
    // Need to verify via ERC721WithCreator.tokensByCreator() that the seller doesn't have any token yet.
    function register(
        string metadataURI
    ) external returns (uint256);

    // @param tokenId
    // @param numberOfIntervals Number of intervals prepaying the tax for
    // @param reservePrice Price that you are taxed on aka value to you (in ETH)
    // @param adMetadataURI IPFS URL for the ad details (tshirt image, etc.)
    function buy(
        uint256 tokenId,
        uint256 numberOfIntervals,
        uint256 reservePrice,
        string adMetadataURI
    ) payable external;

    // Removes seller's token.
    // Verifies that msg.sender equals to ERC721WithCreator.creator(tokenId).
    function delist(
        uint256 tokenId
    ) external;
}
