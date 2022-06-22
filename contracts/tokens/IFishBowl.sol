//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

interface IFishBowl {
    function capacity(uint256 tokenId) external view returns(uint8);
}