//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "../barters/IBarters.sol";
import "../tokens/Fish.sol";
import "../blindbox/IFishGeneBank.sol";
import "../tokens/KOIEarlySupporterNFT.sol";
import "../owner/Controller.sol";

contract BartersKOIEarlySupporterNFT is IBarters, Controller, IERC721Receiver {
    address public override srcNft;
    address public override targetNft;
    uint256 public override total;
    uint256 public sold;

    mapping(uint8 => address) public geneBank; // typeId: gene bank address

    constructor(
        uint32 startTime_,
        uint32 endTime_,
        address srcNft_,
        address targetNft_
    ) Controller("BartersKOIEarlySupporterNFT", startTime_, endTime_) {
        srcNft = srcNft_;
        targetNft = targetNft_;
    }

    function info()
        external
        view
        override
        returns (
            string memory name_,
            address srcNft_,
            address targetNft_,
            uint256 startTime_,
            uint256 endTime_
        )
    {
        name_ = name;
        srcNft_ = srcNft;
        targetNft_ = targetNft;
        startTime_ = startTime;
        endTime_ = endTime;
    }

    function remain() public view override returns (uint256) {
        return total - sold;
    }

    function swap(uint256[] memory srcTokenIdList) external override {
        require(
            block.timestamp >= startTime && block.timestamp < endTime,
            "Non business hours"
        );

        uint256[] memory targetTokenIdList = new uint256[](
            srcTokenIdList.length
        );

        uint256[] memory geneList = new uint256[](srcTokenIdList.length);

        for (uint256 i = 0; i < srcTokenIdList.length; i++) {
            uint256 srcTokenId = srcTokenIdList[i];
            uint8 typeId = KOIEarlySupporterNFT(srcNft).typeId(srcTokenId);

            uint256 gene = IFishGeneBank(geneBank[typeId]).getGenes(1)[0];

            KOIEarlySupporterNFT(srcNft).safeTransferFrom(
                msg.sender,
                address(this),
                srcTokenId
            );

            targetTokenIdList[i] = Fish(targetNft).mint(msg.sender, gene);
            geneList[i] = gene;
        }

        emit Swap(msg.sender, srcTokenIdList, targetTokenIdList, geneList);
    }

    function setNFT(address srcNft_, address targetNft_) external onlyAdmin {
        srcNft = srcNft_;
        targetNft = targetNft_;
    }

    function setGeneBank(uint8[] memory typeIdLs, address[] memory geneBankLs)
        external
        onlyAdmin
    {
        require(
            geneBankLs.length == typeIdLs.length && typeIdLs.length != 0,
            "input err"
        );
        for (uint256 i = 0; i < typeIdLs.length; i++) {
            geneBank[typeIdLs[i]] = geneBankLs[i];
        }
    }

    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }
}
