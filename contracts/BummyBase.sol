// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.17;
 
import "./BummyAccessControl.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "./Interface/BummyBaseInterface.sol";
contract BummyBase is BummyAccessControl, ERC721Enumerable,BummyBaseInterface {

    /// @notice Name and symbol of the non fungible token, ad defined in ERC721

    // COMM: _name, _symbol 사용할 필요 없이 16번째 줄처럼 ERC721 ("BummyNFT", "BV")로 선언하는 것은 어떨지?
    // 만약 _name, _symbol 변수가 필요하다면 ERC721의 name(), symbol() 함수 쓰면 될듯.
    // string _name = "BummyNFT";
    // string _symbol = "BV";

    constructor() ERC721 ("BummyNFT", "BV") {}


    // COMM: BummyId -> bummyId로 변경하는 것은 어떨지? (소문자 시작 convention 맞추기)
    event Invite(address indexed owner, uint256 BummyId, uint256 momId, uint256 dadId, uint256 genes);

    /*** DATA TYPES ***/

    struct Bummy {
        // 버미 유전자
        uint256 genes;

        // 버미가 생겨난 시간
        uint64 birthTime;

        // 교배후 자식 키티가 민팅이 가능해지는 시각, 다음 교배가 가능해지는 시각
        uint64 cooldownEndTime; 
        
        // COMM: 여기도 소문자로 시작하는 컨벤션
        uint32 MomId;
        uint32 DadId;

        // 교배 중인 BummyId
        uint32 cheeringWithId;

        // COMM: 질문) uint8로 충분한지?
        //교배시 1씩 증가하며 교배 쿨타임 기간 증가
        uint8 cooldownIndex;
        //자식 수
        uint8 children;

        // 세대수, 이 값은 부모의 세대에 의해 아래와 같이 결정
        // max(mom.generation, dad.generation) + 1
        uint16 generation;
    }

    // COMM: cooldowns 변수를 굳이 Base에 선언한 이유는? 어차피 Cheering에서 사용할거면 Cheering에 선언해도 좋을 듯
    // + 컨트랙트의 계층이 너무 겹겹이 있어서 함수나 스토리지 변수를 찾기 어렵고, 이 문제는 특히 Upgradeable 컨트랙트 작성할 때 골치가 좀 아픕니다.
    // 되도록이면 계층 분리를 최소화 하는 것을 추천..!

    /*** CONSTANTS ***/
    // COMM: (아이디어)배열 설정할 필요 없이, 2^N minutes만큼 하는 것은 어떨까? 
    // e.g. _bummy.cooldownEndTime = uint64(block.timestamp + (2**n) * 60);
    // -> 장점: storage call 할 필요 없이 단순 연산만으로 cooldowns 계산 가능

    // 어깨동무를 너무 많이 하는 것을 방지하기 위해 
    // cooldown 값이 교배할수록 증가함.
    uint32[8] public cooldowns = [
        uint32(1 minutes),
        uint32(2 minutes),
        uint32(5 minutes),
        uint32(10 minutes),
        uint32(30 minutes),
        uint32(1 hours),
        uint32(2 hours),
        uint32(4 hours)
    ];

    /*** STORAGE ***/

    /// @dev 존재하는 버미들을 저장하는 공간
    /// ID = 0인 버미는 존재할 수 없습니다.
    // COMM: public 키워드 명시해주는 것이 좋습니다.
    Bummy[] bummies;

    
    /// @dev BummyId와 owner를 mapping
    /// BummyId => siring이 허락된 address
    // COMM: 매핑 이름 `allowedCheeringOf`는 어떤지? 좀더 직관적인 변수 명명법 찾아보자.
    mapping (uint256 => address) public cheerAllowedToAddress;

    
    
    /// @dev _tokenId에 해당하는 Bummy를 _from에서 _to로 보냅니다.
    /// 
    function _transfer(address _from, address _to, uint256 _tokenId) override internal virtual {
        if (_from != address(0)) {
            delete cheerAllowedToAddress[_tokenId];    
        }
        super._transfer(_from,_to,_tokenId);
    }

    /// @dev 버미를 생성하고 민팅합니다. 
    /// 이때, tokenId(BummyId)가 정해집니다.  
    /// @param _momId The bummy ID of the mom of this bummy (zero for gen0)
    /// @param _dadId The bummy ID of the dad of this bummy (zero for gen0)
    /// @param _generation The generation number of this bummy, must be computed by caller.
    /// @param _genes The bummy's genetic code.
    /// @param _owner The inital owner of this bummy, must be non-zero (except for the unKitty, ID 0)
    function _createBummy(
        uint256 _momId,
        uint256 _dadId,
        uint256 _generation,
        uint256 _genes,
        address _owner
    ) internal returns (uint)
    {
        /// 세대수와 Id의 최대 가지수
        // COMM: 2**32 - 1 대신 `type(uint32).max`을 사용할 수 있습니다.
        require(_momId <= 2**32 - 1);
        require(_dadId <= 2**32 - 1);
        require(_generation <= 2**16-1);
        
        
        Bummy memory _bummy = Bummy({
            genes: _genes,
            birthTime: uint64(block.timestamp),
            cooldownEndTime: 0,
            MomId: uint32(_momId),
            DadId: uint32(_dadId),
            cheeringWithId: 0,
            cooldownIndex: 0,
            children: 0,
            generation: uint16(_generation)

        });
        bummies.push(_bummy);
        uint256 newBummyId = bummies.length - 1;
        

        require(newBummyId <= 2**32 - 1 );

        // emit the birth event
        emit Invite(
            _owner,
            newBummyId,
            uint256(_bummy.MomId),
            uint256(_bummy.DadId),
            _bummy.genes
        );

        // This will assign ownership, and also emit the Transfer event as
        // per ERC721 draft
        _safeMint(_owner, newBummyId);

        return newBummyId;
    }
}

