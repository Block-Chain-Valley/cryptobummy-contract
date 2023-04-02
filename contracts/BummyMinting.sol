// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.17;

import "./BummyCheering.sol";
import "./Interface/BummyMintingInterface.sol";

/// @title all functions related to creating kittens
contract BummyMinting is BummyCheering, BummyMintingInterface {
    mapping(address => bool) alreadyMinted;

    // COMM: constant로 지정하거나, immutable로 지정하여 constructor에서 초기화 하는 방법을 권장
    // Limits the number of cats the contract owner can ever create.
    uint256 public immutable promoCreationLimit = 100;
    uint256 public immutable gen0CreationLimit = 500;

    // Counts the number of bummies the contract owner has created.
    uint256 public promoCreatedCount;
    uint256 public gen0CreatedCount;

    /// @dev we can create promo bummies, up to a limit. Only callable by COO
    /// @param _genes the encoded genes of the bummies to be created, any value is accepted
    /// @param _owner the future owner of the created bummies. Default to contract COO

    function createPromoBummy(
        uint256 _genes,
        address _owner
    ) external override onlyCOO whenNotPaused {
        if (_owner == address(0)) {
            _owner = msg.sender;
        }
        require(promoCreatedCount < promoCreationLimit);
        require(gen0CreatedCount < gen0CreationLimit);

        promoCreatedCount++;
        gen0CreatedCount++;
        _createBummy(0, 0, 0, _genes, _owner);
    }

    function createPromoMultipleBummy(
        uint256 _genes,
        address _owner,
        uint256 number
    ) external onlyCOO whenNotPaused {
        if (_owner == address(0)) {
            _owner = msg.sender;
        }
        require(promoCreatedCount < promoCreationLimit);
        require(gen0CreatedCount < gen0CreationLimit);
        for (uint256 i = 0; i < number; i++) {
            promoCreatedCount++;
            gen0CreatedCount++;
            _genes++;
            _createBummy(0, 0, 0, _genes, _owner);
        }
    }

    /**
     * @dev user can create gen0bummy, but only one
     */
    // COMM: whenNotPaused 해야 할듯?
    function createFirstGen0Bummy() external whenNotPaused {
        require(alreadyMinted[msg.sender] == false, "You already mint bummy");
        uint256 genes = uint256(
            keccak256(
                abi.encodePacked(
                    block.timestamp,
                    block.difficulty,
                    msg.sender,
                    gen0CreatedCount,
                    block.coinbase
                )
            )
        ); //* choose diffirent rand function
        gen0CreatedCount++;
        alreadyMinted[msg.sender] = true;
        _createBummy(0, 0, 0, genes, msg.sender);
    }
}
