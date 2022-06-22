// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "../lib/Random.sol";
import "../lib/MyMath.sol";
import "./IFishGene.sol";

contract FishGene is IFishGene {
    uint256[][14] private geneIdList;
    uint256[][14] private rarityList;
    uint256[][14] private powerList;
    uint256[11][30] private suitList;
    uint256[30] private suitGroupList;

    constructor() {
        geneIdList[0] = [1, 2, 3, 4];
        geneIdList[1] = [1, 2, 3, 4, 5];
        geneIdList[2] = [1, 2];
        geneIdList[3] = [1, 2, 3, 4];
        geneIdList[4] = [1, 2, 3];
        geneIdList[5] = [1, 2, 3, 4, 5, 6, 7];
        geneIdList[6] = [1, 2, 3];
        geneIdList[7] = [1, 2, 3];
        geneIdList[8] = [0, 1, 2];
        geneIdList[9] = [0];
        geneIdList[10] = [0];
        geneIdList[11] = [0];
        geneIdList[12] = [0];
        geneIdList[13] = [3, 4, 5, 6, 7];
        rarityList[0] = [0, 1, 1, 1];
        rarityList[1] = [0, 1, 2, 2, 3];
        rarityList[2] = [0, 2];
        rarityList[3] = [0, 1, 2, 1];
        rarityList[4] = [0, 1, 1];
        rarityList[5] = [0, 1, 1, 1, 1, 1, 1];
        rarityList[6] = [0, 1, 1];
        rarityList[7] = [0, 1, 1];
        rarityList[8] = [0, 1, 2];
        rarityList[9] = [0];
        rarityList[10] = [0];
        rarityList[11] = [0];
        rarityList[12] = [0];
        rarityList[13] = [0, 0, 1, 2, 3];
        powerList[0] = [12, 25, 28, 31];
        powerList[1] = [11, 25, 48, 53, 85];
        powerList[2] = [9, 60];
        powerList[3] = [8, 30, 58, 32];
        powerList[4] = [7, 30, 28];
        powerList[5] = [8, 26, 32, 26, 29, 30, 29];
        powerList[6] = [10, 28, 35];
        powerList[7] = [9, 26, 27];
        powerList[8] = [0, 30, 70];
        powerList[9] = [0];
        powerList[10] = [0];
        powerList[11] = [0];
        powerList[12] = [0];
        powerList[13] = [0, 0, 0, 0, 0];
        // 6
        suitList[0] = [3, 1, 0, 0, 3, 6, 0, 2, 2, 0, 0];
        suitList[1] = [3, 2, 0, 0, 3, 6, 0, 2, 2, 0, 0];
        suitList[2] = [3, 3, 0, 0, 3, 6, 0, 2, 2, 0, 0];
        suitList[3] = [3, 4, 0, 0, 3, 6, 0, 2, 2, 0, 0];
        suitList[4] = [3, 5, 0, 0, 3, 6, 0, 2, 2, 0, 0];
        // 5
        suitList[5] = [1, 1, 0, 2, 0, 3, 3, 0, 0, 0, 0];
        suitList[6] = [1, 2, 0, 2, 0, 3, 3, 0, 0, 0, 0];
        suitList[7] = [1, 3, 0, 2, 0, 3, 3, 0, 0, 0, 0];
        suitList[8] = [1, 4, 0, 2, 0, 3, 3, 0, 0, 0, 0];
        suitList[9] = [1, 5, 0, 2, 0, 3, 3, 0, 0, 0, 0];
        suitList[10] = [2, 1, 2, 0, 2, 5, 0, 0, 0, 0, 0];
        suitList[11] = [2, 2, 2, 0, 2, 5, 0, 0, 0, 0, 0];
        suitList[12] = [2, 3, 2, 0, 2, 5, 0, 0, 0, 0, 0];
        suitList[13] = [2, 4, 2, 0, 2, 5, 0, 0, 0, 0, 0];
        suitList[14] = [2, 5, 2, 0, 2, 5, 0, 0, 0, 0, 0];
        suitList[15] = [4, 1, 0, 4, 0, 7, 0, 3, 0, 0, 0];
        suitList[16] = [4, 2, 0, 4, 0, 7, 0, 3, 0, 0, 0];
        suitList[17] = [4, 3, 0, 4, 0, 7, 0, 3, 0, 0, 0];
        suitList[18] = [4, 4, 0, 4, 0, 7, 0, 3, 0, 0, 0];
        suitList[19] = [4, 5, 0, 4, 0, 7, 0, 3, 0, 0, 0];
        // 4
        suitList[20] = [1, 1, 0, 0, 0, 2, 2, 0, 0, 0, 0];
        suitList[21] = [1, 2, 0, 0, 0, 2, 2, 0, 0, 0, 0];
        suitList[22] = [1, 3, 0, 0, 0, 2, 2, 0, 0, 0, 0];
        suitList[23] = [1, 4, 0, 0, 0, 2, 2, 0, 0, 0, 0];
        suitList[24] = [1, 5, 0, 0, 0, 2, 2, 0, 0, 0, 0];
        suitList[25] = [2, 1, 0, 3, 0, 4, 0, 0, 0, 0, 0];
        suitList[26] = [2, 2, 0, 3, 0, 4, 0, 0, 0, 0, 0];
        suitList[27] = [2, 3, 0, 3, 0, 4, 0, 0, 0, 0, 0];
        suitList[28] = [2, 4, 0, 3, 0, 4, 0, 0, 0, 0, 0];
        suitList[29] = [2, 5, 0, 3, 0, 4, 0, 0, 0, 0, 0];
        suitGroupList = [
            5,
            5,
            5,
            5,
            5,
            2,
            2,
            2,
            2,
            2,
            4,
            4,
            4,
            4,
            4,
            6,
            6,
            6,
            6,
            6,
            1,
            1,
            1,
            1,
            1,
            3,
            3,
            3,
            3,
            3
        ];
    }

    function geneSplit(uint256 gene)
        public
        pure
        returns (uint256[] memory geneLs)
    {
        geneLs = new uint256[](14);
        for (uint256 i = 0; i < 14; i++) {
            uint256 n = 1000**(13 - i);
            geneLs[i] = gene / n;
            gene -= geneLs[i] * n;
        }
    }

    function geneMerge(uint256[] memory geneLs)
        public
        pure
        returns (uint256 gene)
    {
        for (uint256 i = 0; i < 14; i++) {
            gene += geneLs[i] * 1000**(13 - i);
        }
    }

    function suitBuff(uint256 suit, uint256 geneItemPower)
        public
        pure
        returns (uint256 powerBuff)
    {
        if (suit == 4) {
            powerBuff = geneItemPower / 2;
        } else if (suit == 5) {
            powerBuff = geneItemPower;
        } else if (suit == 6) {
            powerBuff = geneItemPower * 2;
        } else if (suit == 7) {
            powerBuff = geneItemPower * 4;
        } else {
            powerBuff = 0;
        }
    }

    function getSuit(uint256 gene) public view override returns (uint256) {
        return getSuit(geneSplit(gene));
    }

    function getSuit(uint256[] memory geneLs) internal view returns (uint256) {
        uint256 suit = 0;
        for (uint256 i = 0; i < 30; i++) {
            for (uint256 j = 0; j < 11; j++) {
                if (suitList[i][j] == 0) {
                    continue;
                }
                if (suitList[i][j] == geneLs[j]) {
                    suit += 1;
                    continue;
                }
                suit = 0;
                break;
            }

            if (suit != 0) {
                return suit;
            }
        }

        return suit;
    }

    function getSuitGroup(uint256 gene)
        public
        view
        override
        returns (uint256, uint256)
    {
        return getSuitGroup(geneSplit(gene));
    }

    function getSuitGroup(uint256[] memory geneLs)
        internal
        view
        returns (uint256, uint256)
    {
        uint256 suit = 0;
        for (uint256 i = 0; i < 30; i++) {
            for (uint256 j = 0; j < 8; j++) {
                if (suitList[i][j] == 0) {
                    continue;
                }
                if (suitList[i][j] == geneLs[j]) {
                    suit += 1;
                    continue;
                }
                suit = 0;
                break;
            }

            if (suit != 0) {
                return (suit, suitGroupList[i]);
            }
        }

        return (0, 0);
    }

    function getPower(uint256 gene)
        public
        view
        override
        returns (uint256 power)
    {
        power = getPower(geneSplit(gene));
    }

    function getPower(uint256[] memory geneLs)
        internal
        view
        returns (uint256 power)
    {
        uint256 suit = getSuit(geneLs);

        for (uint256 i = 0; i < 14; i++) {
            uint256 geneIndex = getGeneIndex(i, geneLs[i]);
            uint256 onePower = powerList[i][geneIndex];
            onePower *= 100; // * 100
            power += (onePower + suitBuff(suit, onePower));
        }
        power = MyMath.div(power, 100); // / 100 round
    }

    // function getColor(uint256 gene) public view returns (uint256 power) {
    //     gene / 1000
    // }

    function newGene(uint256 gene0, uint256 gene1)
        public
        view
        override
        returns (uint256)
    {
        uint256[] memory geneLs0 = geneSplit(gene0);
        uint256[] memory geneLs1 = geneSplit(gene1);
        uint256[] memory newGeneLs = new uint256[](14);

        uint256 rand = Random.randint(
            10**14,
            10**15,
            uint256(uint160(msg.sender))
        );

        for (uint256 i = 0; i < 14; i++) {
            newGeneLs[i] = (rand % 2 == 0) ? geneLs0[i] : geneLs1[i];
            rand /= 10;
        }

        return geneMerge(mutation(newGeneLs));
    }

    function mutation(uint256[] memory geneLs)
        public
        view
        returns (uint256[] memory)
    {
        uint256[] memory randLs = Random.randSec100(
            14,
            uint256(uint160(msg.sender))
        );

        for (uint256 i = 0; i < 14; i++) {
            uint256 geneIndex = getGeneIndex(i, geneLs[i]);
            uint256 rarity = rarityList[i][geneIndex];
            uint256 newGeneItem;

            if (randLs[i] < 1) {
                newGeneItem = getAdvanced(i, rarity, randLs[i]);
            } else if (
                (rarity == 1 && randLs[i] > 76) ||
                (rarity == 2 && randLs[i] > 61) ||
                (rarity == 3 && randLs[i] >= 50)
            ) {
                newGeneItem = getNormal(i, randLs[i]);
            }

            if (newGeneItem > 0) {
                geneLs[i] = newGeneItem;
            }
        }
        return geneLs;
    }

    function getGeneIndex(uint256 pos, uint256 geneId)
        public
        view
        returns (uint256)
    {
        for (uint256 i = 0; i < geneIdList[pos].length; i++) {
            if (geneIdList[pos][i] == geneId) {
                return i;
            }
        }

        require(false, "getGeneIndex Err");
        return 0;
    }

    function getNormal(uint256 pos, uint256 ran) public view returns (uint256) {
        uint256 len = rarityList[pos].length;
        uint256[] memory normalGeneLs = new uint256[](len);
        uint256 cnt = 0;

        for (uint256 i = 0; i < len; i++) {
            if (rarityList[pos][i] == 0) {
                normalGeneLs[cnt] = geneIdList[pos][i];
                cnt++;
            }
        }

        if (cnt == 0) {
            return 1;
        }

        return normalGeneLs[ran % cnt];
    }

    function getAdvanced(
        uint256 pos,
        uint256 rarity,
        uint256 ran
    ) public view returns (uint256 geneItem) {
        uint256 len = rarityList[pos].length;
        uint256[] memory advancedGeneLs = new uint256[](len);
        uint256 cnt = 0;

        for (uint256 i = 0; i < len; i++) {
            if (rarityList[pos][i] == rarity + 1) {
                advancedGeneLs[cnt] = geneIdList[pos][i];
                cnt++;
            }
        }

        if (cnt == 0) {
            return 0;
        }

        return advancedGeneLs[ran % cnt];
    }
}
