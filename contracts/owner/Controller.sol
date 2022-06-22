//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;
import "./AdminRole.sol";

contract Controller is AdminRole {
    event NameUpdate(string oldName, string newName);
    event SetTime(uint32 startTime, uint32 endTime);

    string public name;
    uint32 public startTime;
    uint32 public endTime;

    constructor(
        string memory name_,
        uint32 startTime_,
        uint32 endTime_
    ) {
        name = name_;
        startTime = startTime_;
        endTime = endTime_;
    }

    function setName(string memory name_) external onlyAdmin {
        emit NameUpdate(name, name_);
        name = name_;
    }

    function setTime(uint32 startTime_, uint32 endTime_) external onlyAdmin {
        startTime = startTime_;
        endTime = endTime_;

        emit SetTime(startTime, endTime);
    }

    modifier checkTime(){
        require(
            block.timestamp >= startTime && block.timestamp < endTime,
            "The current time contract is not executable"
        );
        _;
    }
}
