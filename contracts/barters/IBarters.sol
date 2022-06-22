//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

interface IBarters {
    function srcNft() external view returns (address);

    function targetNft() external view returns (address);

    function total() external view returns (uint256);

    function remain() external view returns (uint256);

    function info()
        external
        view
        returns (
            string memory name_,
            address srcNft_,
            address targetNft_,
            uint256 startTime_,
            uint256 endTime_
        );
    
    function swap(uint256[] memory srcTokenIdList) external;

    event Swap(address user, uint256[] srcTokenIdList, uint256[] targetTokenIdList, uint256[] geneList);
}

interface IBarters1155to721 {
    function srcNft() external view returns (address);

    function srcNftId() external view returns (uint256);

    function targetNft() external view returns (address);

    function total() external view returns (uint256);

    function remain() external view returns (uint256);

    function info()
        external
        view
        returns (
            string memory name_,
            address srcNft_,
            uint256 srcNftId_,
            address targetNft_,
            uint256 startTime_,
            uint256 endTime_
        );
    
    function swap(uint256 count) external;

    event Swap(address user, uint256[] fishTokenIdList, uint256[] geneList);
}