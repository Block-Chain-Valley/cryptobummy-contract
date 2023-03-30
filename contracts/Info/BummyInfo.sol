// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.17;

import "../Interface/BummyInfoInterface.sol";
import "../Interface/BummyCoreInterface.sol";
import "hardhat/console.sol";
contract BummyInfo is BummyInfoInterface {
    bool public isBummyInfo = true;
    uint private randNonce = 0;
    BummyCoreInterface _bummyCore;

    constructor(address _bummyCoreAddress) {
        require(_bummyCoreAddress != address(0));
        _bummyCore = BummyCoreInterface(_bummyCoreAddress);
       
    }

    /// @dev the function as defined in the breeding contract - as defined in CK bible
    function mixGenes(
        uint256 _genes1,
        uint256 _genes2
    ) external override returns (uint256) {
        return _mixGenes(_genes1, _genes2);
    }

    function _mixGenes(
        uint256 _genes1,
        uint256 _genes2
    ) internal returns (uint256) {
        uint randomNumber = uint(keccak256(abi.encodePacked(block.timestamp, block.difficulty, msg.sender, randNonce)));
        randNonce++;
        uint256 newGene= _genes1 + _genes2 + randomNumber;
        return newGene;
    }

}