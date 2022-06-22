// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "../owner/AdminRole.sol";
import "./IWhitelist.sol";

contract Whitelist is IWhitelist, AdminRole{
    using EnumerableSet for EnumerableSet.AddressSet;
 
    EnumerableSet.AddressSet private _accountsSet;

    function contains(address account) external view override returns(bool) {
        return _accountsSet.contains(account);
    }

    function length() external view override returns(uint256) {
        return _accountsSet.length();
    }

    function list() external view override returns(address[] memory accounts) {
        accounts = new address[](_accountsSet.length());
        for (uint256 i = 0; i < _accountsSet.length(); i++) {
            accounts[i] = _accountsSet.at(i);
        }
    }

    function add(address[] memory accounts) external override onlyAdmin{
        for (uint16 i = 0; i < accounts.length; i++){
             _accountsSet.add(accounts[i]);
        }
    }

    function remove(address[] memory accounts) external override onlyAdmin{
        for (uint16 i = 0; i < accounts.length; i++){
            _accountsSet.remove(accounts[i]);
        }
    }
}
