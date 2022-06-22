// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;
import "../lib/Random.sol";
import "./IFishGeneBank.sol";
import "../owner/AdminRole.sol";

contract FishGeneBank2 is IFishGeneBank, AdminRole {
    uint256[] private _geneList;
    uint256[] private _suiteGeneList;

    function getGenes(uint8 count)
        external
        view
        override
        returns (uint256[] memory geneArray)
    {
        geneArray = new uint256[](count);
        uint32[] memory randArray = Random.randSec(count, uint256(uint160(msg.sender)));
        for(uint256 i = 0; i < count; i++){
            uint256 num = randArray[i] % 5000;
            if(num >= _suiteGeneList.length){
                num = num % 100;
                geneArray[i] = _geneList[num];
            }else{
                geneArray[i] = _suiteGeneList[num];
            }   
        }
    }

    function pushGenes(uint256[] memory genes) external onlyAdmin {
        for(uint256 i = 0; i < genes.length; i++){
            _geneList.push(genes[i]);
        }
    }

    function pushSuiteGenes(uint256[] memory genes) external onlyAdmin {
        for(uint256 i = 0; i < genes.length; i++){
            _suiteGeneList.push(genes[i]);
        }
    }
}
