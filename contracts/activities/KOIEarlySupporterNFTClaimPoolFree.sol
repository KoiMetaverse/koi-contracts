//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;
import "./IKOIEarlySupporterNFTClaimPool.sol";
import "../tokens/KOIEarlySupporterNFT.sol";
import "../owner/AdminRole.sol";

contract KOIEarlySupporterNFTClaimPoolFree is IKOIEarlySupporterNFTClaimPool, AdminRole {
    string public override name;
    address public override nft;
    uint256 public override startTime;
    uint256 public override endTime;
    mapping(uint8 => uint8) public typeCount; // typeId: number of available
    mapping(address => mapping(uint8 => uint8)) public userCount; // account: {typeId: Received number}

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

    function inWhiteList(address) public pure override returns(bool) {
        return true;
    }

    function userRemain(address account, uint8 typeId) public view override returns(uint8) {
        if(userCount[account][typeId] >= typeCount[typeId]){
            return 0;
        }
        return typeCount[typeId] - userCount[account][typeId];
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
            count > 0 && count <= userRemain(msg.sender, typeId),
            "claim count err"
        );
        

        uint256[] memory tokenIdList = new uint256[](count);

        for (uint256 i = 0; i < count; i++) {
            tokenIdList[i] = KOIEarlySupporterNFT(nft).mint(
                msg.sender, typeId
            );
        }

        userCount[msg.sender][typeId] += count;

        emit Claim(msg.sender, typeId, tokenIdList);
    }

    function setNFT(address nft_) external onlyAdmin {
        nft = nft_;
    }

    function setTime(uint256 startTime_, uint256 endTime_) external onlyAdmin {
        startTime = startTime_;
        endTime = endTime_;
    }

    function setTypeCount(uint8 typeId, uint8 count) external onlyAdmin {
        typeCount[typeId] = count;
    }

}
