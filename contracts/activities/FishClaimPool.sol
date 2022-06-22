//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;
import "./IFishClaimPool.sol";
import "../tokens/Fish.sol";
import "../owner/Controller.sol";
import "../blindbox/IFishGeneBank.sol";

contract FishClaimPool is IFishClaimPool, Controller {
    address public override nft;
    mapping(address => uint8) public override userRemain;
    IFishGeneBank public fishGeneBank;

    constructor(
        uint32 startTime_,
        uint32 endTime_,
        address nft_,
        address fishGeneBank_
    ) Controller("FishClaimPool_chainboost", startTime_, endTime_) {
        nft = nft_;
        fishGeneBank = IFishGeneBank(fishGeneBank_);
    }

    function inWhiteList(address account) public view override returns(bool) {
        return userRemain[account] > 0;
    }

    function info()
        external
        view
        override
        returns (
            string memory name_,
            address nft_,
            uint32 startTime_,
            uint32 endTime_
        )
    {
        name_ = name;
        nft_ = nft;
        startTime_ = startTime;
        endTime_ = endTime;
    }

    function claim(uint8 count) external override checkTime {
        require(
            count > 0 && count <= userRemain[msg.sender],
            "claim count err"
        );
        
        uint256[] memory tokenIdList = new uint256[](count);
        uint256[] memory geneList = fishGeneBank.getGenes(count);

        for (uint256 i = 0; i < count; i++) {
            tokenIdList[i] = Fish(nft).mint(
                msg.sender, geneList[i]
            );
        }

        userRemain[msg.sender] -= count;

        emit Claim(msg.sender, tokenIdList, geneList);
    }

    function setNFT(address nft_) external onlyAdmin {
        nft = nft_;
    }

    function setUserRemain(address[] memory userLs, uint8[] memory countLs)
        external
        onlyAdmin
    {
        require(userLs.length == countLs.length && userLs.length != 0, "input err");
        for (uint256 i = 0; i < userLs.length; i++) {
            if(userRemain[userLs[i]] == countLs[i]){
                continue;
            }
            userRemain[userLs[i]] = countLs[i];
        }
    }

    function setFishGeneBank(address fishGeneBank_) external onlyAdmin {
        fishGeneBank = IFishGeneBank(fishGeneBank_);
    }
}
