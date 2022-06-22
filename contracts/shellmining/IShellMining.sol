// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../tokens/IFishStatus.sol";

interface IShellMining {

    function nft() external view returns(address);

    function coin() external view returns(address);

    function totalNft() external view returns (uint256);

    function totalNftPower() external view returns (uint256);

    function totalFishOriginalPower() external view returns (uint256);

    function myNft(uint256 limit, uint256 offset) external view returns (IFishStatus.FishInfo[] memory);

    function getNft(uint256 tokenId) external view returns (IFishStatus.FishInfo memory);

    function earned() external view returns (uint256);

    function stakeNft(uint256[] memory tokenIds) external;

    function withdrawNft(uint256[] memory tokenIds) external;

    function withdrawNftAll() external;

    function getReward() external;

    function exit() external;

    event Stake(address user, uint256[] tokenIds);

    event Withdraw(address user, uint256[] tokenIds);

    event Reward(address user, uint256 amount);
}
