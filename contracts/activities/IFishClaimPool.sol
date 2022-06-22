//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

interface IFishClaimPool {
    function nft() external view returns (address);

    function info()
        external
        view
        returns (
            string memory name_,
            address nft_,
            uint32 startTime_,
            uint32 endTime_
        );
    function inWhiteList(address account) external view returns(bool);

    function userRemain(address account) external view returns (uint8);
    
    function claim(uint8 count) external;

    event Claim(address user, uint256[] tokenIdList, uint256[] geneList);
}