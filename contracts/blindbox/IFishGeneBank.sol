//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

interface IFishGeneBank {
    function getGenes(uint8 count)
        external
        view
        returns (
            uint256[] memory geneArray
        );
}

// interface IFishGeneData {
//     function get(uint32 number)
//         external
//         view
//         returns (
//             uint256 gene,
//             uint16 power
//         );
// }