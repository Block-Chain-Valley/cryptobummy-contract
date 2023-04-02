// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.17;


import './BummyCheering.sol';
import "./Interface/BummyMintingInterface.sol";
/// @title all functions related to creating kittens
contract BummyMinting is BummyCheering, BummyMintingInterface {
    mapping(address => bool) alreadyMinted;
    
    // COMM: constant로 지정하거나, immutable로 지정하여 constructor에서 초기화 하는 방법을 권장
    // Limits the number of cats the contract owner can ever create.
    uint256 public promoCreationLimit = 100;
    uint256 public gen0CreationLimit = 500;

    // Counts the number of bummies the contract owner has created.
    uint256 public promoCreatedCount;
    uint256 public gen0CreatedCount;

    /// @dev we can create promo bummies, up to a limit. Only callable by COO
    /// @param _genes the encoded genes of the bummies to be created, any value is accepted
    /// @param _owner the future owner of the created bummies. Default to contract COO
    // COMM: 100개 Bummy를 만드려면 COO가 이 함수를 100번 실행해야 하는지? 한 번에 여러 개 하는 방법은 없을지?
    // COMM: whenNotPaused 해야 할듯?
    function createPromoBummy(uint256 _genes, address _owner) external override onlyCOO {
        if (_owner == address(0)) {
            // COMM: onlyCOO modifier에서 msg.sender가 COO인 것이 보장되었으므로
            // _owner = cooAddress; 대신 _owner = msg.sender가 가스 효율적입니다.
            // (cooAddress를 호출하는 것은 storage load이기 때문)
            _owner = cooAddress;
        }
        require(promoCreatedCount < promoCreationLimit);
        require(gen0CreatedCount < gen0CreationLimit);

        promoCreatedCount++;
        gen0CreatedCount++;
        _createBummy(0, 0, 0, _genes, _owner);
        
    }

    /**
     * @dev user can create gen0bummy, but only one
     */
    // COMM: whenNotPaused 해야 할듯?
    function createFirstGen0Bummy() external {
        require(alreadyMinted[msg.sender] == false, "You already mint bummy");
        uint256 genes = block.timestamp ^ gen0CreatedCount; //* choose diffirent rand function
        gen0CreatedCount++;
        alreadyMinted[msg.sender] = true;
       _createBummy(0, 0, 0, genes, msg.sender);
    }
}
