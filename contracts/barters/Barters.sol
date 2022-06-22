//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import "./IBarters.sol";
import "../tokens/Fish.sol";
import "../blindbox/IFishGeneBank.sol";
import "../tokens/KOIEarlySupporterNFT.sol";
import "../owner/Controller.sol";

contract Barters is IBarters1155to721, Controller, ERC1155Holder {
    address public override srcNft;
    uint256 public override srcNftId = 1;
    address public override targetNft;
    uint256 public override total;
    uint256 public sold;
    IFishGeneBank public fishGeneBank;

    constructor(
        uint32 startTime_,
        uint32 endTime_,
        address srcNft_,
        address targetNft_,
        uint256 total_,
        address fishGeneBank_
    ) Controller("Barters", startTime_, endTime_) {
        srcNft = srcNft_;
        targetNft = targetNft_;
        total = total_;
        fishGeneBank = IFishGeneBank(fishGeneBank_);
    }

    function info()
        external
        view
        override
        returns (
            string memory name_,
            address srcNft_,
            uint256 srcNftId_,
            address targetNft_,
            uint256 startTime_,
            uint256 endTime_
        )
    {
        name_ = name;
        srcNft_ = srcNft;
        srcNftId_ = srcNftId;
        targetNft_ = targetNft;
        startTime_ = startTime;
        endTime_ = endTime;
    }

    function remain() public view override returns (uint256) {
        return total - sold;
    }

    function swap(uint256 count) external override checkTime {
        require(count <= remain(), "wrong quantity");

        IERC1155(srcNft).safeTransferFrom(
            msg.sender,
            address(this),
            srcNftId,
            count,
            ""
        );

        uint256[] memory fishTokenIdList = new uint256[](count);
        uint256[] memory geneList = fishGeneBank.getGenes(uint8(count));

        for (uint256 i = 0; i < count; i++) {
            fishTokenIdList[i] = Fish(targetNft).mint(
                msg.sender,
                geneList[i]
            );
        }

        sold += count;

        emit Swap(msg.sender, fishTokenIdList, geneList);
    }

    function setNFT(
        address srcNft_,
        uint256 srcNftId_,
        address targetNft_
    ) external onlyAdmin {
        srcNft = srcNft_;
        srcNftId = srcNftId_;
        targetNft = targetNft_;
    }

    function setTotal(uint256 total_) external onlyAdmin {
        total = total_;
    }

    function setFishGeneBank(address fishGeneBank_) external onlyAdmin {
        fishGeneBank = IFishGeneBank(fishGeneBank_);
    }

    function tansfer(address account, uint256 count) external onlyAdmin {
        IERC1155(srcNft).safeTransferFrom(
            address(this),
            account,
            srcNftId,
            count,
            ""
        );
    }
}
