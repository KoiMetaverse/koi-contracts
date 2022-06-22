//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

interface IFish {
    function gene(uint256 tokenId) external view returns(uint256);

    function birthday(uint256 tokenId) external view returns(uint32);

    function fishInfo(uint256 tokenId) external view returns(
        uint256 gene_, 
        uint32 birthday_
    );

    function fishIdList(address account) external view returns(uint256[] memory);
}