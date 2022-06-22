// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../tokens/IFishStatus.sol";

interface IKoiMining {

    function nft() external view returns(address);

    function coin() external view returns(address);

    function groupIds() external view returns (uint8[] memory);

    function dailyOutput() external view returns (uint256[] memory);

    function totalNft() external view returns (uint256[] memory);

    function totalNftPoint() external view returns (uint256[] memory);

    function myNft() external view returns (IFishStatus.FishInfo[] memory, uint8[] memory); //fish info list, groupId list.

    function earned() external view returns (uint256);

    function stakeNft(uint256 tokenId, uint8 groupId) external;

    function withdrawNft(uint256 tokenId) external;

    function withdrawNftAll() external;

    function getReward() external;

    function exit() external;

    event Stake(address user, uint256 tokenId, uint8 groupId);

    event Withdraw(address user, uint256 tokenId, uint8 groupId);

    event Reward(address user, uint256 amount);
}
