//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;
import "./Controller.sol";

contract Treasury is Controller {
    event TreasuryUpdate(address oldTreasury, address newTreasury);

    address payable public treasury;

    constructor(
        string memory name_,
        uint32 startTime_,
        uint32 endTime_,
        address treasury_
    ) Controller(name_, startTime_, endTime_) {
        treasury = payable(treasury_);
    }

    function setTreasury(address treasury_) external onlyAdmin {
        emit TreasuryUpdate(treasury, treasury_);
        treasury = payable(treasury_);
    }
}
