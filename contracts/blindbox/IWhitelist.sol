//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

interface IWhitelist {
    function contains(address account) external view returns(bool);

    function length() external view returns(uint256);

    function list() external view returns(address[] memory accounts);

    function add(address[] memory accounts) external;

    function remove(address[] memory accounts) external;
}