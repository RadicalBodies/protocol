// @title Radical Bodies market.
interface IMarket {
    // The ERC721 token.
    function token() external view returns (address);

    // The advertisement period in seconds.
    function interval() external view returns (uint256);

    // The tax rate in basis points, 0 to 1000000.
    function taxRatePerInterval() external view returns (uint256);

    // The precision of the calculation. To get a floating point number,
    // divide taxRatePerInterval with taxPrecision.
    function taxPrecision() external pure returns (uint256);

    // The minimum bid/increase. (in ETH)
    function epsilon() external view returns (uint256);

    // The beneficiary receiving all the funds.
    function beneficiary() external view returns (address);

    // The beneficiary can retrieve already released funds via this.
    function withdrawAvailableFunds() external payable;

    // The current price of the given token.
    function priceOf(uint256 tokenId) external view returns (uint256);

    // The period the token is taxed until.
    function taxedUntil(uint256 tokenId) external view returns (uint256);

    // Returns the starting timestamp of the current period.
    function currentPeriodStart() external view returns (uint256);

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
    //
    // nextPeriodStart = timestamp of next hour
    // previousPeriodStart = nextPeriodStart - interval
    //
    // Calculate costs:
    //   nextPrice = currentPrice + epsilon
    //   tax = nextPrice * taxRatePerInterval * numberOfIntervals
    //   msg.value >= nextPrice + tax
    //
    // Refund extra ETH.
    //
    // Check if current owner has still some prepaid interval left,
    // if so they must be refunded:
    //   refundInterval = (taxedUntil - previousPeriodStart) / interval
    //   refund = refundInterval * taxRatePerInterval
    //
    // taxedUntil = previousPeriodStart + interval * numberOfIntervals
    function buy(
        uint256 tokenId,
        uint256 numberOfIntervals,
        uint256 reservePrice,
        string adMetadataURI
    ) payable external;

    // Returns the calculated price for the token.
    // If the reservePrice is less than the minimum price, this fails (reverts).
    function calculatePrice(
      uint256 tokenId,
      uint256 numberOfIntervals,
      uint256 reservePrice
    ) view external returns (
      uint256 periodStart,
      uint256 price,
      uint256 tax
    );

    // Removes seller's token.
    // Verifies that msg.sender equals to ERC721WithCreator.creator(tokenId).
    function delist(
        uint256 tokenId
    ) external;

    // Only in the paused state. Disassembles everything, refunds stuff, etc.
    function teardown() external;
}
