pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "openzeppelin-solidity/contracts/lifecycle/Pausable.sol";

import "./IMarket.sol";
import "./IProperty.sol";

// @title Radical Bodies market.
contract Market is IMarket, Ownable, Pausable {
    IProperty private _token;
    uint256 private _interval;
    uint256 private _taxRatePerInterval;
    uint256 private _epsilon;
    address private _beneficiary;

    mapping (uint256 => uint256) private tokenPrice;
    mapping (uint256 => uint256) private tokenTaxedUntil;

    constructor(
        IProperty token,
        uint256 interval,
        uint256 taxRatePerInterval,
        uint256 epsilon,
        address beneficiary
    ) {
        _token = token;
        _interval = interval;
        _taxRatePerInterval = taxRatePerInterval;
        _epsilon = epsilon;
        _beneficiary = beneficiary;
    }

    // The ERC721 token.
    function token() external view returns (address) {
        return address(_token);
    }

    // The advertisement period in seconds.
    function interval() external view returns (uint256) {
        return _interval;
    }

    // The tax rate in basis points, 0 to 1000000.
    function taxRatePerInterval() external view returns (uint256) {
        return _taxRatePerInterval;
    }

    // The minimum bid/increase. (in ETH)
    function epsilon() external view returns (uint256) {
        return _epsilon;
    }

    // The beneficiary receiving all the funds.
    function beneficiary() external view returns (address) {
        return _beneficiary;
    }

    // The beneficiary can retrieve already released funds via this.
    function withdrawAvailableFunds() external payable {
        // @todo implement

        assert(false);
    }

    // The current price of the given token.
    function priceOf(uint256 tokenId) external view returns (uint256) {
        return tokenPrice[tokenId];
    }

    // The period the token is taxed until.
    function taxedUntil(uint256 tokenId) external view returns (uint256) {
        return tokenTaxedUntil[tokenId];
    }

    // Creates a new token. ERC721 + ERC721Metadata
    // @param metadataURI IPFS URL for all the user details
    // @returns the tokenId
    //
    // Uses msg.sender as token owner. Calls mintWithTokenURI(msg.sender, <tokenId>, metadataURI);
    //
    // Need to verify via ERC721WithCreator.tokensByCreator() that the seller doesn't have any token yet.
    function register(
        string metadataURI
    ) external whenNotPaused returns (uint256) {
        // Check seller doesn't have a token yet
        require(_token.tokensByCreator(msg.sender).length == 0);

        // Create token for seller
        uint256 tokenId = _token.totalSupply();
        require(_token.mintWithTokenURI(msg.sender, tokenId, metadataURI));

        return tokenId;
    }

    // @param tokenId
    // @param numberOfIntervals Number of intervals prepaying the tax for
    // @param reservePrice Price that you are taxed on aka value to you (in ETH)
    // @param adMetadataURI IPFS URL for the ad details (tshirt image, etc.)
    function buy(
        uint256 tokenId,
        uint256 numberOfIntervals,
        uint256 reservePrice,
        string adMetadataURI
    ) payable external whenNotPaused {
        address currentOwner = _token.ownerOf(tokenId);

        // Timestamp of the current period starrt.
        uint256 currentPeriodStart = (block.timestamp / _interval) * _interval;

        uint256 currentPrice = tokenPrice[tokenId];
        uint256 nextPrice = currentPrice + _epsilon;

        uint256 tax = nextPrice * _taxRatePerInterval * numberOfIntervals;

        uint256 totalCost = nextPrice + tax;

        require(msg.value >= totalCost);

        // Refund excess tax paid.
        if (currentOwner != _token.creatorOfToken(tokenId)) {
            uint256 refundInterval = (tokenTaxedUntil[tokenId] - currentPeriodStart) / _interval;
            uint256 refund = refundInterval * _taxRatePerInterval;

            currentOwner.transfer(refund);

            totalCost += refund;
        }

        // Refund excess payment.
        if (msg.value > totalCost)
            msg.sender.transfer(msg.value - totalCost);

        // Transfer token and update properties.
        _token.transferFrom(currentOwner, msg.sender, tokenId);
        tokenTaxedUntil[tokenId] = currentPeriodStart + _interval * numberOfIntervals;
        tokenPrice[tokenId] = nextPrice;
    }

    // Removes seller's token.
    // Verifies that msg.sender equals to ERC721WithCreator.creator(tokenId).
    function delist(
        uint256 tokenId
    ) external whenNotPaused {
        require(_token.creatorOfToken(tokenId) == msg.sender);

        _token.burn(tokenId);
    }

    function teardown() external onlyOwner {
        // @todo implement

        assert(false);
    }
}
