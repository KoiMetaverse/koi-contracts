//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

interface IFishStatus {
    struct FishInfo {
        uint256 tokenId;
        uint256 gene; 
        uint256 birthday;
        uint256 power;
        uint256 level;
        uint256 point;
        uint256 shellMiningTimes;
        uint256 koiMiningTimes;
        uint256 breedingTimes;    
    }

    function gene(uint256 tokenId) external view returns (uint256);

    function birthday(uint256 tokenId) external view returns (uint256);

    function power(uint256 tokenId) external view returns (uint256);

    function level(uint256 tokenId) external view returns (uint256);

    function point(uint256 tokenId) external view returns (uint256);

    function shellMiningTimes(uint256 tokenId) external view returns (uint256);

    function koiMiningTimes(uint256 tokenId) external view returns (uint256);

    function breedingTimes(uint256 tokenId) external view returns (uint256);

    function fishInfo(uint256 tokenIds) external view returns(FishInfo memory);

    function fishList(uint256[] memory tokenIds) external view returns(FishInfo[] memory);

    function setShellMiningTimes(uint256 tokenId, uint256 shellMiningTimes_) external;

    function setKoiMiningTimes(uint256 tokenId, uint256 koiMiningTimes_) external;

    function breedingTimesAdd(uint256 tokenId) external;

    function setLevel(uint256 tokenId, uint256 level_) external;
}