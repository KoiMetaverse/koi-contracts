//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

interface IFishRoe {
    function colour(uint256 tokenId) external view returns(uint8);

    function suit(uint256 tokenId) external view returns(uint8);

    function fishRoeInfo(uint256 tokenId) external view returns(
        uint8 colour_, 
        uint8 suit_
    );
}