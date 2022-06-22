//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;
import "../owner/AdminRole.sol";
import "./IFish.sol";
import "./IFishStatus.sol";
import "./IFishGene.sol";

contract FishStatus is IFishStatus, AdminRole {
    struct FishData {
        uint16 shellMiningTimes;
        uint16 koiMiningTimes;
        uint16 breedingTimes;
        uint16 level;
    }

    IFish public fish;
    IFishGene public fishGene;

    mapping(uint256 => FishData) public fishDataMap;

    constructor(address fish_, address fishGene_) {
        fish = IFish(fish_);
        fishGene = IFishGene(fishGene_);
    }

    function point(uint256 tokenId) public view override returns (uint256) {
        uint256 suit;
        uint256 groupId;
        (suit, groupId) = fishGene.getSuitGroup(gene(tokenId));

        uint256 point_;
        uint256 level_ = fishDataMap[tokenId].level;

        if (suit == 4) {
            point_ = 10;
        } else if (suit == 5) {
            point_ = 20;
        } else if (suit == 6) {
            point_ = 40;
        } else if (suit == 7) {
            point_ = 80;
        } else {
            return 0;
        }

        if (level_ == 2) {
            point_ = (point_ * 3) / 2;
        } else if (level_ == 3) {
            point_ *= 2;
        } else if (level_ == 4) {
            point_ *= 3;
        }

        return point_;
    }

    function gene(uint256 tokenId) public view override returns (uint256) {
        return fish.gene(tokenId);
    }

    function birthday(uint256 tokenId) public view override returns (uint256) {
        return fish.birthday(tokenId);
    }

    function power(uint256 tokenId) public view override returns (uint256) {
        return fishGene.getPower(gene(tokenId));
    }

    function level(uint256 tokenId) public view override returns (uint256) {
        return fishDataMap[tokenId].level;
    }

    function shellMiningTimes(uint256 tokenId)
        public
        view
        override
        returns (uint256)
    {
        return fishDataMap[tokenId].shellMiningTimes;
    }

    function koiMiningTimes(uint256 tokenId)
        public
        view
        override
        returns (uint256)
    {
        return fishDataMap[tokenId].koiMiningTimes;
    }

    function breedingTimes(uint256 tokenId)
        public
        view
        override
        returns (uint256)
    {
        return fishDataMap[tokenId].breedingTimes;
    }

    function fishInfo(uint256 tokenId)
        public
        view
        override
        returns (FishInfo memory)
    {
        FishInfo memory fInfo;
        (fInfo.gene, fInfo.birthday) = fish.fishInfo(tokenId);
        fInfo.power = power(tokenId);
        fInfo.shellMiningTimes = fishDataMap[tokenId].shellMiningTimes;
        fInfo.koiMiningTimes = fishDataMap[tokenId].koiMiningTimes;
        fInfo.breedingTimes = fishDataMap[tokenId].breedingTimes;
        fInfo.level = fishDataMap[tokenId].level;
        fInfo.point = point(tokenId);
        fInfo.tokenId = tokenId;
        return fInfo;
    }

    function fishList(uint256[] memory tokenIds)
        external
        view
        override
        returns (FishInfo[] memory)
    {
        FishInfo[] memory fishs = new FishInfo[](tokenIds.length);
        for (uint256 i = 0; i < tokenIds.length; i++) {
            fishs[i] = fishInfo(tokenIds[i]);
        }
        return fishs;
    }

    function setShellMiningTimes(uint256 tokenId, uint256 shellMiningTimes_)
        external
        override
        onlyAdmin
    {
        fishDataMap[tokenId].shellMiningTimes = uint16(shellMiningTimes_);
    }

    function setKoiMiningTimes(uint256 tokenId, uint256 koiMiningTimes_)
        external
        override
        onlyAdmin
    {
        fishDataMap[tokenId].koiMiningTimes = uint16(koiMiningTimes_);
    }

    function breedingTimesAdd(uint256 tokenId) external override onlyAdmin {
        fishDataMap[tokenId].breedingTimes++;
    }

    function setLevel(uint256 tokenId, uint256 level_) external override onlyAdmin {
        fishDataMap[tokenId].level = uint16(level_);
    }

    function setFish(address fish_) external onlyAdmin {
        fish = IFish(fish_);
    }

    function setFishGene(address fishGene_) external onlyAdmin {
        fishGene = IFishGene(fishGene_);
    }

    function load(address oldFishStatus_, uint256[] memory tokenIds)
        external
        onlyAdmin
    {
        IFishStatus oldFishStatus = IFishStatus(oldFishStatus_);

        for (uint256 i = 0; i < tokenIds.length; i++) {
            uint256 tokenId = tokenIds[i];

            if (oldFishStatus.shellMiningTimes(tokenId) != 0) {
                fishDataMap[tokenId].shellMiningTimes = uint16(oldFishStatus
                    .shellMiningTimes(tokenId));
            }

            if (oldFishStatus.koiMiningTimes(tokenId) != 0) {
                fishDataMap[tokenId].koiMiningTimes = uint16(oldFishStatus
                    .koiMiningTimes(tokenId));
            }

            if (oldFishStatus.breedingTimes(tokenId) != 0) {
                fishDataMap[tokenId].breedingTimes = uint16(oldFishStatus
                    .breedingTimes(tokenId));
            }

            if (oldFishStatus.level(tokenId) != 0) {
                fishDataMap[tokenId].level = uint16(oldFishStatus.level(tokenId));
            }
        }
    }
}
