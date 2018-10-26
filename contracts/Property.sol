pragma solidity ^0.4.20;

import "openzeppelin-solidity/contracts/token/ERC721/ERC721Full.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

contract Property is ERC721Full, Ownable {

    function mint(address to, uint256 tokenId) public onlyOwner returns (bool) {

        // @todo add in all the stuff to store who the creator was etc.

        _mint(to, tokenId);
        return true;
    }

}
