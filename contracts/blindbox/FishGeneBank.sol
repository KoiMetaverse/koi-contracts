// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;
import "../lib/Random.sol";
import "./IFishGeneBank.sol";
import "../owner/AdminRole.sol";

contract FishGeneBank is IFishGeneBank, AdminRole {
    uint256[] private _geneList;

    function getGenes(uint8 count)
        external
        view
        override
        returns (uint256[] memory geneArray)
    {
        geneArray = new uint256[](count);
        uint32[] memory randArray = Random.randSec(count, uint256(uint160(msg.sender)));
        for(uint8 i = 0; i < count; i++){
            uint256 num = randArray[i] % _geneList.length;
            geneArray[i] = _geneList[num];
        }
    }

    function pushData(uint256[] memory genes) external onlyAdmin {
        for(uint256 i = 0; i < genes.length; i++){
            _geneList.push(genes[i]);
        }
    }
}
