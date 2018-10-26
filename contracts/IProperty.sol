pragma solidity ^0.4.20;

import "openzeppelin-solidity/contracts/token/ERC721/IERC721Full.sol";
import "./IERC721WithCreator.sol";

contract IProperty is IERC721Full, IERC721WithCreator {
    // D'oh. openzeppelin doesn't have an interface for ERC721Mintable/ERC721MetadataMintable.
    function mintWithTokenUri(address to, uint256 tokenId, string tokenURI) external returns (bool);
    function burn(uint256 tokenId) external returns (bool);
}
