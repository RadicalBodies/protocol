pragma solidity ^0.4.20;

import "openzeppelin-solidity/contracts/token/ERC721/ERC721Full.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "./IERC721WithCreator.sol";

contract Property is ERC721Full, Ownable, IERC721WithCreator {

    mapping (uint256 => address) private creators;
    mapping (address => uint256[]) private tokensByCreator;

    function mint(address to, uint256 tokenId) external onlyOwner returns (bool) {
        _mint(to, tokenId);

        creators[tokenId] = to;
        tokensByCreator[to].push(tokenId);

        return true;
    }

    function burn(uint256 tokenId) external onlyOwner returns (bool) {
        delete creators[tokenId];

        // @todo delete from tokensByCreator array

        _burn(owner, tokenId);
        return true;
    }

    function creator(uint256 tokenId) external view returns (address) {
        return creators[tokenId];
    }

    function tokensByCreator(address creator) external view returns (uint256[]) {
        return tokensByCreator[creator];
    }

}
