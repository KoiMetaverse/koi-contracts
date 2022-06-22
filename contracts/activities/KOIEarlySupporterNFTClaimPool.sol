//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "./IKOIEarlySupporterNFTClaimPool.sol";
import "../tokens/KOIEarlySupporterNFT.sol";
import "../owner/AdminRole.sol";

contract KOIEarlySupporterNFTClaimPool is IKOIEarlySupporterNFTClaimPool, AdminRole {
    using EnumerableSet for EnumerableSet.AddressSet;

    string public override name;
    address public override nft;
    uint256 public override startTime;
    uint256 public override endTime;
    mapping(address => mapping(uint8 => uint8)) public override userRemain;

    EnumerableSet.AddressSet private _userSet;

    constructor(
        string memory name_,
        address nft_,
        uint256 startTime_,
        uint256 endTime_
    ) {
        name = name_;
        nft = nft_;
        startTime = startTime_;
        endTime = endTime_;
    }

    function inWhiteList(address account) public view override returns(bool) {
        return _userSet.contains(account);
    }

    function info()
        external
        view
        override
        returns (
            string memory name_,
            address nft_,
            uint256 startTime_,
            uint256 endTime_
        )
    {
        name_ = name;
        nft_ = nft;
        startTime_ = startTime;
        endTime_ = endTime;
    }

    function claim(uint8 typeId, uint8 count) external override {
        require(
            block.timestamp >= startTime && block.timestamp < endTime,
            "Non business hours"
        );

        require(
            inWhiteList(msg.sender),
            "you are not on the whitelist"
        );

        require(
            count > 0 && count <= userRemain[msg.sender][typeId],
            "claim count err"
        );
        

        uint256[] memory tokenIdList = new uint256[](count);

        for (uint256 i = 0; i < count; i++) {
            tokenIdList[i] = KOIEarlySupporterNFT(nft).mint(
                msg.sender, typeId
            );
        }

        userRemain[msg.sender][typeId] -= count;

        emit Claim(msg.sender, typeId, tokenIdList);
    }

    function setNFT(address nft_) external onlyAdmin {
        nft = nft_;
    }

    function setTime(uint256 startTime_, uint256 endTime_) external onlyAdmin {
        startTime = startTime_;
        endTime = endTime_;
    }

    function updateUserRemain(address[] memory userLs, uint8[] memory typeIdLs, uint8[] memory countLs)
        external
        onlyAdmin
    {
        require(userLs.length == typeIdLs.length && userLs.length == countLs.length && userLs.length != 0, "input err");
        for (uint256 i = 0; i < userLs.length; i++) {
            if(userRemain[userLs[i]][typeIdLs[i]] == countLs[i]){
                continue;
            }
            userRemain[userLs[i]][typeIdLs[i]] = countLs[i];
            if(!inWhiteList(userLs[i])){
                _userSet.add(userLs[i]);
            }
        }
    }

    function removeWhiteList(address[] memory accounts) external onlyAdmin{
        for (uint16 i = 0; i < accounts.length; i++){
            if(inWhiteList(accounts[i])){
                _userSet.remove(accounts[i]);
            }
        }
    }
}
