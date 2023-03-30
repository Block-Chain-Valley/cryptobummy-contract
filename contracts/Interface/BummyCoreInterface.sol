// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.17;
interface BummyCoreInterface {
    
    //* BummyCore
    
    /**
     * @dev 토큰 아이디를 넣으면 해당하는 버미에 대한 정보가 나옵니다.
     * @param _id token id
     * @return isGestating 
     * @return isReady 
     * @return cooldownIndex 
     * @return nextActionAt 
     * @return cheeringWithId 
     * @return birthTime 
     * @return momId 
     * @return dadId 
     * @return generation 
     * @return genes 
     */
    function getBummy(uint256 _id)
        external
        view
        returns (
        bool isGestating,
        bool isReady,
        uint256 cooldownIndex,
        uint256 nextActionAt,
        uint256 cheeringWithId,
        uint256 birthTime,
        uint256 momId,
        uint256 dadId,
        uint256 generation,
        uint256 genes
    );
}