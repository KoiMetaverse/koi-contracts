// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./KoiMining.sol";
// import "hardhat/console.sol";

contract MockKoiMining is KoiMining {

    constructor(
        uint32 startTime_,
        uint32 endTime_,
        address nft_,
        address fishGene_,
        address fishStatus_,
        address coin_
    ) KoiMining(startTime_, endTime_, nft_, fishGene_, fishStatus_, coin_) {
    }

    uint256 public __epoch;

    function currentEpoch() public override view returns (uint256) {
        return __epoch;
    }

    function setEpoch(uint256 epoch_) public {
        __epoch = epoch_;
    }
}
