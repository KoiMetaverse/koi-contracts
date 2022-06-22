// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;
import "../owner/AdminRole.sol";
import "./IInvitation.sol";

contract Invitation is IInvitation, AdminRole{

    mapping(address => uint32) public inviterCodeMap;
    mapping(uint32 => address) public codeInviterMap;
    mapping(address => uint32) public inviteeCodeMap;
    mapping(uint32 => address[]) public codeInviteesMap;
    uint32 public startCode = 100001;
    uint32 public nextCode = startCode;

    function getCode(address account) external view override returns(uint32){
        return inviterCodeMap[account];
    }

    function getInviter(address account) external view override returns(address){
        uint32 code = inviteeCodeMap[account];
        if(code != 0){
            return codeInviterMap[code];
        }
        return address(0);
    }

    function inviteesCount(address account) external view override returns(uint256){
        uint32 code = inviterCodeMap[account];
        if(code == 0){
            return 0;
        }
        return codeInviteesMap[code].length;
    }

    function getInvitees(address account, uint256 limit, uint256 offset) external view override returns(address[] memory accounts){
        uint32 code = inviterCodeMap[account];
        if(code == 0){
            return accounts;
        }

        if(codeInviteesMap[code].length == 0){
            return accounts;
        }

        uint256 length = limit;

        if(codeInviteesMap[code].length < offset + limit){
            length = offset + limit - codeInviteesMap[code].length;
        }

        accounts = new address[](length);
        for(uint256 i = 0; i < length; i++){
            accounts[i] = codeInviteesMap[code][offset + i];
        }
    }

    function inputCode(uint32 code) external override {
        require(code >= startCode && code < nextCode, "code err");
        require(inviteeCodeMap[msg.sender] == 0, "Can't enter a second time");

        inviteeCodeMap[msg.sender] = code;
        codeInviteesMap[code].push(msg.sender);
    }

    function createCode(address account) external override onlyAdmin{
        if(inviterCodeMap[account] == 0){
            inviterCodeMap[account] = nextCode;
            codeInviterMap[nextCode] = account;
            nextCode++;
        }
    }
}
