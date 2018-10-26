pragma solidity ^0.4.20;

import "openzeppelin-solidity/contracts/token/ERC721/IERC721Full.sol";
import "./IERC721WithCreator.sol";

contract IProperty is IERC721Full, IERC721WithCreator {
}
