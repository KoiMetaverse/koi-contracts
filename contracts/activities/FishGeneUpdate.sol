//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "../tokens/Fish.sol";
import "../owner/Controller.sol";

contract FishGeneUpdate is Controller, IERC721Receiver {
    Fish public fish;

    constructor(
        uint32 startTime_,
        uint32 endTime_,
        address nft_
    ) Controller("FishGeneUpdate", startTime_, endTime_) {
        fish = Fish(nft_);
    }

    function update() external checkTime {
        uint256[] memory tokenIdList = fish.fishIdList(msg.sender);
        uint256 n = 10 ** 33;
        uint256 cnt = 0;

        for (uint256 i = 0; i < tokenIdList.length; i++) {
            uint256 tokenId = tokenIdList[i];
            uint256 gene = fish.gene(tokenId);
            if(gene / n % 10 == 4){
                gene -= n * 2;
                fish.safeTransferFrom(msg.sender, address(this), tokenId);
                fish.mint(msg.sender, gene);
                cnt++;
            }
        }

        emit Update(msg.sender, cnt);
    }

    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }

    event Update(address user, uint256 cnt);
}
