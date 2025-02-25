// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract MockMintableERC721 is ERC721, Ownable {
    struct Metadata {
        address token0;
        address token1;
        uint256 amount0;
        uint256 amount1;
        uint256 liquidity;
        uint256 timestamp;
    }

    uint256 private _tokenId;
    mapping(uint256 tokenId_ => Metadata) private _metadata;

    constructor(string memory name_, string memory symbol_, address owner_) ERC721(name_, symbol_) Ownable(owner_) {
        _tokenId = 0;
    }

    function mint(address to_, address token0_, address token1_, uint256 amount0_, uint256 amount1_, uint256 liquidity_)
        external
        onlyOwner
        returns (uint256 tokenId)
    {
        _tokenId++;
        _metadata[_tokenId] = Metadata(token0_, token1_, amount0_, amount1_, liquidity_, block.timestamp);
        _mint(to_, _tokenId);

        return _tokenId;
    }

    function burn(uint256 tokenId_) external onlyOwner {
        _burn(tokenId_);
        delete _metadata[tokenId_];
    }

    function updateMetadata(uint256 tokenId_, Metadata memory metadata_) external onlyOwner {
        _metadata[tokenId_] = metadata_;
    }

    function getMetadata(uint256 tokenId_) external view returns (Metadata memory) {
        return _metadata[tokenId_];
    }
}
