pragma solidity ^0.4.24;

/**
 * @title ERC-721 optional "variable metadata" extension
 */
contract IERC721VariableMetadata {
  // Retrieve the currently set variable metadata.
  function variableMetadataURI(uint256 tokenId) external view returns (string);

  // Replace the variable metadata.
  function replaceVariableMetadataURI(uint256 tokenId, string metadataURI) external;
}
