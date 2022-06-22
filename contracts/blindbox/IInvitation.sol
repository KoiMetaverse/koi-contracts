//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

interface IInvitation {
    function getCode(address account) external view returns(uint32);

    function getInviter(address account) external view returns(address);

    function inviteesCount(address account) external view returns(uint256);

    function getInvitees(address account, uint256 limit, uint256 offset) external view returns(address[] memory accounts);

    function inputCode(uint32 code) external;

    function createCode(address account) external;
}