//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

interface IKOIEarlySupporterNFT {
    function typeId(uint256 tokenId) external view returns(uint8);

    function list(address account) external view returns(uint256[] memory tokenIds, uint8[] memory typeIds);
}