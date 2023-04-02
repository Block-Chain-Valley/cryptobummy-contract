// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.17;

import "./BummyMinting.sol";
import "./Interface/BummyCoreInterface.sol";

contract BummyCore is BummyMinting, BummyCoreInterface {
    /// @notice Creates Bummy Contracts
    constructor() {
        _pause();
        ceoAddress = msg.sender;
        cooAddress = msg.sender;

        _createBummy(
            0,
            0,
            0,
            type(uint256).max,
            address(0x000000000000000000000000000000000000dEaD)
        );
    }

    /// @notice Returns all the relevant information about a specific bummy.
    /// @param _id The ID of the bummy of interest.
    // COMM: return을 다 uint256으로 하는 이유가 있나?
    // 원래 struct type대로 uint32, uint16 등등으로 리턴하는 게 메모리 적게 사용할듯.
    function getBummy(
        uint32 _id
    )
        external
        view
        returns (
            bool isCheering,
            bool isReady,
            uint256 cooldownIndex,
            uint256 nextActionAt,
            uint256 cheeringWithId,
            uint256 birthTime,
            uint256 momId,
            uint256 dadId,
            uint256 generation,
            uint256 genes
        )
    {
        // COMM: memory로 선언
        Bummy memory bum = bummies[_id];

        // if this variable is 0 then it's not Exhausted
        isCheering = (bum.cheeringWithId != 0);
        isReady = (bum.cooldownEndTime <= block.timestamp);
        cooldownIndex = uint256(bum.cooldownIndex);
        nextActionAt = uint256(bum.cooldownEndTime);
        cheeringWithId = uint256(bum.cheeringWithId);
        birthTime = uint256(bum.birthTime);
        momId = uint256(bum.MomId);
        dadId = uint256(bum.DadId);
        generation = uint256(bum.generation);
        genes = bum.genes;
    }
}
