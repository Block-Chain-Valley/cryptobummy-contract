import { ethers } from "hardhat";
import { BummyCore } from "../typechain-types";
import { BigNumber } from "ethers";

// export const deployCB = async () => {
//     const CBFactory = await ethers.getContractFactory("BummyCore");
//     const cb = await CBFactory.deploy();
//     console.log(cb.address);
// }

const cbAddress = "0x5FbDB2315678afecb367f032d93F642f64180aa3";

export const getInviteEvents = async () => {
    const [deployer, user2, user3] = await ethers.getSigners();
    
    const cryptoBummy = await ethers.getContractAt("BummyCore", cbAddress) as BummyCore;

    const tx = await cryptoBummy.createFirstGen0Bummy();
    const receipt = await tx.wait();


    // INVITE 이벤트 추출
    // 1. event signature => keccak("Invite(address,uint256,uint256,uint256,uint256)")
    // 0x14cb614758d3c982e9d2ae0ad129c2c2bdb4c5ba841155dced7bed1a27834de7
    const INVITE_SIG = "0x14cb614758d3c982e9d2ae0ad129c2c2bdb4c5ba841155dced7bed1a27834de7";
    const inviteEvent = receipt.logs.filter(log => {
        log.topics[0] === INVITE_SIG
    });

    const ie = inviteEvent[0];
    let [, owner] = ie.topics;
    owner = "0x" + owner.slice(-40, 0);
    
    const BummyId = BigNumber.from("0x" + ie.data.slice(2, 2+64)).toString();
    const momId = BigNumber.from("0x" + ie.data.slice(2+64, 2+128)).toString();
    const dadId = BigNumber.from("0x" + ie.data.slice(2+128, 2+192)).toString();
    const genes = BigNumber.from("0x" + ie.data.slice(2+192, 2+256)).toString();
    
    const block = await ethers.provider.getBlock(tx.blockNumber!);

    const invite = {
        blockNumber: tx.blockNumber,
        createdAt: new Date(block.timestamp * 1000),
        owner,
        BummyId,
        momId,
        dadId,
        genes,
    }
}

getInviteEvents();