// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IBreeding {
    function nft() external view returns (address);

    function coin() external view returns (address);

    function getFee(uint256 fatherId, uint256 motherId)
        external
        view
        returns (uint256 fee);

    function breeding(uint256 fatherId, uint256 motherId) external;

    event Breeding(
        address user,
        uint256 fatherId,
        uint256 motherId,
        uint256 childId,
        uint256 childGene,
        uint256 fee
    );
}
