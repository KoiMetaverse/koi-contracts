// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./ShellMining1.sol";
// import "hardhat/console.sol";

contract MockShellMining is ShellMining1 {

    constructor(
        uint32 startTime_,
        uint32 endTime_,
        address nft_,
        address fishStatus_,
        address coin_
    ) ShellMining1(startTime_, endTime_, nft_, fishStatus_, coin_) {
    }

    uint256 public __epoch;

    function currentEpoch() public override view returns (uint256) {
        return __epoch;
    }

    function setEpoch(uint256 epoch_) public {
        __epoch = epoch_;
    }
}
