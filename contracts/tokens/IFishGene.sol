// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IFishGene {
    function getSuit(uint256 gene) external view returns (uint256);

    function getSuitGroup(uint256 gene)
        external
        view
        returns (uint256, uint256);

    function getPower(uint256 gene) external view returns (uint256 power);

    function newGene(uint256 gene0, uint256 gene1)
        external
        view
        returns (uint256);
}
