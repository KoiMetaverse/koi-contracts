//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

interface IKOIEarlySupporterNFTClaimPool {
    function name() external view returns (string memory);

    function nft() external view returns (address);

    function startTime() external view returns (uint256);

    function endTime() external view returns (uint256);

    function info()
        external
        view
        returns (
            string memory name_,
            address nft_,
            uint256 startTime_,
            uint256 endTime_
        );
    function inWhiteList(address account) external view returns(bool);

    function userRemain(address, uint8 typeId) external view returns (uint8);
    
    function claim(uint8 typeId, uint8 count) external;

    event Claim(address user, uint8 typeId, uint256[] tokenIdList);
}