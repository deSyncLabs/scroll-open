// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {INonfungiblePositionManager} from "@uniswap/v3-periphery/contracts/interfaces/INonfungiblePositionManager.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import {MockMintableERC721} from "./MockMintableERC721.sol";
import {IMintableERC20} from "src/interfaces/IMintableERC20.sol";
import {RayMath} from "lib/RayMath.sol";

contract MockNonFungiblePositionManager is Ownable {
    error NFTNotOwned();

    MockMintableERC721 private _mintableERC721;
    uint256 private _apy;

    modifier onlyNFTOwner(uint256 tokenId) {
        if (_mintableERC721.ownerOf(tokenId) != msg.sender) {
            revert NFTNotOwned();
        }

        _;
    }

    constructor(uint256 apy_, address owner_) Ownable(owner_) {
        _apy = apy_;
        _mintableERC721 = new MockMintableERC721("PositionNFT", "PNFT", address(this));
    }

    function mint(INonfungiblePositionManager.MintParams memory params_)
        external
        returns (uint256, uint128, uint256, uint256)
    {
        IMintableERC20(params_.token0)._burn_(msg.sender, params_.amount0Desired);
        IMintableERC20(params_.token1)._burn_(msg.sender, params_.amount1Desired);

        uint256 tokenId = _mintableERC721.mint(
            params_.recipient, params_.token0, params_.token1, params_.amount0Desired, params_.amount1Desired, 1
        );

        return (tokenId, 1, params_.amount0Desired, params_.amount1Desired);
    }

    function increaseLiquidity(INonfungiblePositionManager.IncreaseLiquidityParams memory params_)
        external
        onlyNFTOwner(params_.tokenId)
        returns (uint128, uint256, uint256)
    {
        MockMintableERC721.Metadata memory metadata = _mintableERC721.getMetadata(params_.tokenId);

        (uint256 interest0, uint256 interest1) = _collect(metadata);

        IMintableERC20(metadata.token0)._burn_(msg.sender, params_.amount0Desired);
        IMintableERC20(metadata.token1)._burn_(msg.sender, params_.amount1Desired);

        _mintableERC721.updateMetadata(
            params_.tokenId,
            MockMintableERC721.Metadata(
                metadata.token0,
                metadata.token1,
                metadata.amount0 + params_.amount0Desired + interest0,
                metadata.amount1 + params_.amount1Desired + interest1,
                1,
                block.timestamp
            )
        );

        return (1, params_.amount0Desired, params_.amount1Desired);
    }

    function decreaseLiquidity(INonfungiblePositionManager.DecreaseLiquidityParams memory params_)
        external
        onlyNFTOwner(params_.tokenId)
        returns (uint256, uint256)
    {
        MockMintableERC721.Metadata memory metadata = _mintableERC721.getMetadata(params_.tokenId);

        (uint256 interest0, uint256 interest1) = _collect(metadata);

        IMintableERC20(metadata.token0)._mint_(msg.sender, metadata.amount0);
        IMintableERC20(metadata.token1)._mint_(msg.sender, metadata.amount1);

        IMintableERC20(metadata.token0).transfer(msg.sender, interest0);
        IMintableERC20(metadata.token1).transfer(msg.sender, interest1);

        _mintableERC721.updateMetadata(
            params_.tokenId, MockMintableERC721.Metadata(metadata.token0, metadata.token1, 0, 0, 0, block.timestamp)
        );

        return (metadata.amount0 + interest0, metadata.amount1 + interest1);
    }

    function collect(INonfungiblePositionManager.CollectParams memory params_)
        external
        onlyNFTOwner(params_.tokenId)
        returns (uint256, uint256)
    {
        MockMintableERC721.Metadata memory metadata = _mintableERC721.getMetadata(params_.tokenId);

        (uint256 interest0, uint256 interest1) = _collect(metadata);

        _mintableERC721.updateMetadata(
            params_.tokenId,
            MockMintableERC721.Metadata(
                metadata.token0,
                metadata.token1,
                metadata.amount0,
                metadata.amount1,
                metadata.liquidity,
                block.timestamp
            )
        );

        IMintableERC20(metadata.token0).transfer(msg.sender, interest0);
        IMintableERC20(metadata.token1).transfer(msg.sender, interest1);

        return (interest0, interest1);
    }

    function _collect(MockMintableERC721.Metadata memory metadata_) private returns (uint256, uint256) {
        uint256 amount0 = metadata_.amount0;
        uint256 amount1 = metadata_.amount1;
        uint256 timestamp = metadata_.timestamp;

        uint256 timeDiff = block.timestamp - timestamp;

        uint256 interestRatePerSecond = _apy / 365 days;

        uint256 interest0 =
            (amount0 * interestRatePerSecond * timeDiff * IERC20Metadata(metadata_.token0).decimals() / RayMath.RAY) / 2;
        uint256 interest1 =
            (amount1 * interestRatePerSecond * timeDiff * IERC20Metadata(metadata_.token1).decimals() / RayMath.RAY) / 2;

        IMintableERC20(metadata_.token0)._mint_(address(this), interest0);
        IMintableERC20(metadata_.token1)._mint_(address(this), interest1);

        return (interest0, interest1);
    }

    function setApy(uint256 apy_) external onlyOwner {
        _apy = apy_;
    }

    function apy() external view returns (uint256) {
        return _apy;
    }
}
