// @title ERC-721 with creator
//
// The creator here is the original creator of the given token.
interface IERC721WithCreator {
    // Returns the original creator of this token.
    function creator(uint256 tokenId) external view returns (address);

    // Returns the tokenIds of the creator.
    function tokensByCreator(address creator) external view returns (uint256[]);
}
