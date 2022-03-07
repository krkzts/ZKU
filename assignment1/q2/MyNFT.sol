// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "hardhat/console.sol";

contract MyNFT is ERC721URIStorage {
    using Counters for Counters.Counter; // for keeping track of tokenIds

    Counters.Counter private _tokenIds;

    // A array representing the merkle tree
    bytes32[] private _merkleTree;
    // A variable representing the merkle root
    bytes32 private _merkleRoot;
    // A constant representing a Number of NFTs to be supplied
    uint256 constant NFTNums = 64;

    // Pass the name of the NFT token and its symbol
    constructor() ERC721("MyNFT", "my") {}

    // A function that mint the NFT to any address
    function makeNFT(address to) public {
        // Get the current tokenId
        uint256 tokenId = _tokenIds.current();

        // Get the JSON metadata(name, description) in place and base64 encode it
        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        "{",
                        '"name": "',
                        Strings.toString(tokenId),
                        '",',
                        '"description": "id: ',
                        Strings.toString(tokenId),
                        '."',
                        "}"
                    )
                )
            )
        );

        // Generate from the JSON
        string memory tokenURI = string(
            abi.encodePacked("data:application/json;base64,", json)
        );

        // Mint the NFT to the sender
        _safeMint(to, tokenId);

        // Set the NFTs data
        _setTokenURI(tokenId, tokenURI);

        // Print a logging message
        console.log(
            "The NFT(id: %s, uri: %s) has been minted to %s",
            tokenId,
            tokenURI,
            to
        );

        // Increment tokenIds
        _tokenIds.increment();
        // Commit the leaf to the merkle tree
        _commitLeafToMerkleTree(to, tokenId, tokenURI);
    }

    // A function that commit the leaf to the merkle tree
    function _commitLeafToMerkleTree(
        address _to,
        uint256 tokenId,
        string memory tokenURI
    ) private {
        // Push the leaf to the array representing the merkle tree
        _merkleTree.push(
            keccak256(abi.encodePacked(msg.sender, _to, tokenId, tokenURI))
        );
        uint256 leafNums = _merkleTree.length;
        bytes32[NFTNums] memory nodes;
        // If the number of leaves is odd, use the last element at the end to calculate the merkle root
        if (leafNums % 2 == 1 && leafNums != 1) {
            for (uint256 i = 2; i < 2 * leafNums - 1; i += 2) {
                nodes[i / 2 + leafNums - 1] = keccak256(
                    abi.encodePacked(_merkleTree[i - 2], _merkleTree[i - 1])
                );
            }
            _merkleRoot = keccak256(
                abi.encodePacked(
                    nodes[2 * leafNums - 2],
                    _merkleTree[leafNums - 1]
                )
            );
        } else if (leafNums % 2 == 0) {
            // If the number of leaves is even
            for (uint256 i = 2; i < 2 * leafNums - 1; i += 2) {
                nodes[i / 2 + leafNums - 1] = keccak256(
                    abi.encodePacked(_merkleTree[i - 2], _merkleTree[i - 1])
                );
            }
            _merkleRoot = nodes[2 * leafNums - 2];
        } else {
            // If you commit the first leaf
            _merkleRoot = _merkleTree[0];
        }
    }
}
