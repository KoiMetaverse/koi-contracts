//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

library Random {
    function randint(
        uint256 begin,
        uint256 end,
        uint256 salt
    ) internal view returns (uint256) {
        uint256 ran = uint256(
            keccak256(abi.encodePacked(block.timestamp, block.difficulty, salt))
        );
        return (ran % (end - begin)) + begin;
    }

    function randint2(
        uint256 begin,
        uint256 end,
        uint256 salt
    ) internal view returns (uint256) {
        uint256 ran = uint256(
            keccak256(
                abi.encodePacked(
                    block.timestamp,
                    uint256(uint160(msg.sender)),
                    salt
                )
            )
        );
        ran =
            uint256(keccak256(abi.encodePacked(block.difficulty, ran))) %
            (end - begin);
        return ran + begin;
    }

    function randomChoices(
        uint8[] memory seq,
        uint8[] memory weights,
        uint256 salt
    ) internal view returns (uint8) {
        require(
            seq.length == weights.length,
            "The length of array string is not equal!"
        );

        uint8 cum = 0;
        uint8[] memory cumWeights;
        for (uint8 i = 0; i < weights.length; i++) {
            cum += weights[i];
            cumWeights[i] = cum;
        }

        uint8 num = uint8(randint2(0, uint256(cum), salt));
        for (uint8 j = 0; j < cumWeights.length; j++) {
            if (num < cumWeights[j]) {
                return seq[j];
            }
        }
        return 0;
    }

    function randSec(uint8 count, uint256 salt)
        internal
        view
        returns (uint32[] memory)
    {
        uint256 ran = uint256(
            keccak256(abi.encodePacked(block.timestamp, block.difficulty, salt))
        ) / 10**10;
        uint32[] memory randArray = new uint32[](count);
        for (uint8 i = 0; i < count; i++) {
            ran = lcg(ran);
            randArray[i] = uint32(ran);
        }
        return randArray;
    }

    function lcg(uint256 rand) internal pure returns (uint256) {
        uint256 a = 1664525;
        uint256 b = 1013904223;
        uint256 m = 2**32;
        return (a * rand + b) % m;
    }

    function randSec100(uint8 count, uint256 salt)
        internal
        view
        returns (uint256[] memory)
    {
        uint256 ran = randint(100 ** count, 100 ** (count + 2), salt);
        uint256[] memory randArray = new uint256[](count);
        for (uint8 i = 0; i < count; i++) {
            randArray[i] = ran % 100;
            ran /= 100;
        }
        return randArray;
    }
}
