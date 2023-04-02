// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/security/Pausable.sol";
import "./Interface/BummyAccessInterface.sol";
contract BummyAccessControl is Pausable,BummyAccessInterface{

    // COMM: 어차피 address type이므로 변수명에서 "address" 빼도 좋을 듯.
    // The addresses of the accounts (or contracts) that can execute actions within each roles.
    address public ceoAddress;//컨트랙트에서 import하는 컨트랙트 주소를 세팅해주는 역할의 계정
    address public cfoAddress;//kitty Core 컨트랙트에서 돈을 인출하는 역할의 계정 
    address public cooAddress;//크립토키티의 전반적인 운영에 기여하는 계정

    /// @dev Access modifier for CEO-only functionality
    modifier onlyCEO() {
        require(msg.sender == ceoAddress);
        _;
    }

    /// @dev Access modifier for CFO-only functionality
    modifier onlyCFO() {
        require(msg.sender == cfoAddress);
        _;
    }

    /// @dev Access modifier for COO-only functionality
    modifier onlyCOO() {
        require(msg.sender == cooAddress);
        _;
    }

    modifier onlyCLevel() {
        require(
            msg.sender == cooAddress ||
            msg.sender == ceoAddress ||
            msg.sender == cfoAddress
        );
        _;
    }

    /// @dev Assigns a new address to act as the CEO. Only available to the current CEO.
    /// @param _newCEO The address of the new CEO
    function setCEO(address _newCEO) external onlyCEO {
        require(_newCEO != address(0));

        ceoAddress = _newCEO;
    }

    /// @dev Assigns a new address to act as the COO. Only available to the current CEO.
    /// @param _newCOO The address of the new COO
    function setCOO(address _newCOO) external onlyCEO {
        require(_newCOO != address(0));

        cooAddress = _newCOO;
    }

    // COMM: setCFO는 없나요?


    /// @dev Called by any "C-level" role to pause the contract. Used only when
    ///  a bug or exploit is detected and we need to limit damage.
    function pause() public onlyCLevel {
        _pause();
    }

    /// @dev Unpauses the smart contract. Can only be called by the CEO, since
    ///  one reason we may pause the contract is when CFO or COO accounts are
    ///  compromised.
    function unpause() public virtual onlyCEO {
        // can't unpause if contract was upgraded
        _unpause();
    }
}
