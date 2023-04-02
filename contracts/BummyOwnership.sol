// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.17;

import "./BummyBase.sol";
import "./Interface/BummyOwnershipInterface.sol";

contract BummyOwnership is BummyBase, BummyOwnershipInterface {
    /// @dev _tokenId에 해당하는 token의 owner가 _claimant 과 동일하면 true 아니면 false를 반환
    /// @param _claimant the address we are validating against.
    /// @param _tokenId bummy id, only valid when > 0
    function _owns(
        address _claimant,
        uint256 _tokenId
    ) internal view returns (bool) {
        return (_claimant == ownerOf(_tokenId));
    }
}
