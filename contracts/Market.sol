pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "openzeppelin-solidity/contracts/lifecycle/Pausable.sol";

import "./IMarket.sol";
import "./IProperty.sol";

// @title Radical Bodies market.
contract Market is IMarket, Ownable, Pausable {
    IProperty private _token;
    uint256 private _taxRate;
    uint256 private _epsilon;
    address private _beneficiary;

    constructor(
        IProperty token,
        uint256 taxRate,
        uint256 epsilon,
        address beneficiary
    ) {
        _token = token;
        _taxRate = taxRate;
        _epsilon = epsilon;
        _beneficiary = beneficiary;
    }

    // The ERC721 token.
    function token() external view returns (address) {
        return address(_token);
    }

    // The tax rate in basis points, 0 to 1000000.
    function taxRate() external view returns (uint256) {
        return _taxRate;
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
        // @todo implement

        assert(false);
    }

    // Removes seller's token.
    // Verifies that msg.sender equals to ERC721WithCreator.creator(tokenId).
    function delist(
        uint256 tokenId
    ) external whenNotPaused {
        require(_token.creatorOfToken(tokenId) == msg.sender);

        _token.burn(tokenId);
    }
}
