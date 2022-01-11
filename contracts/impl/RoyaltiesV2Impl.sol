// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./AbstractRoyalties.sol";
import "../royalties/contracts/RoyaltiesV2.sol";

contract RoyaltiesV2Impl is AbstractRoyalties, RoyaltiesV2 {
    function getRaribleV2Royalties(uint256 id)
        external
        view
        override
        returns (LibPart.Part[] memory)
    {
        return royalties[id];
    }

    function _onRoyaltiesSet(uint256 _id, LibPart.Part[] memory _royalties)
        internal
        override
    {
        emit RoyaltiesSet(_id, _royalties);
    }

    function royaltyInfo(uint256 _tokenId, uint256 _salePrice)
        external
        view
        returns (address receiver, uint256 royaltyAmount)
    {
        return royalties[id];
    }
}
