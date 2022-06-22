//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "../owner/AdminRole.sol";
import "./IKOIEarlySupporterNFT.sol";

contract KOIEarlySupporterNFT is IKOIEarlySupporterNFT, ERC721Enumerable, AdminRole {
    uint256 public nextId;

    // 1 KOI Early Supporter
    // 2 KOI TechTalk
    // 3 Sponge NFT
    // 4 KOI Quiz NFT
    // 5 Fishship NFT
    // 6 Marketplace Tester NFT
    // 7 KOI Ranking NFT -- Neon Guppy
    // 8 KOI Ranking NFT -- Dinoshark
    // 9 KOI Ranking NFT -- Rockstar
    // 10 KOI Ranking NFT -- Leggenda Fish
    mapping(uint256 => uint8) public override typeId;

    string private __baseURI =
        "http://metadata.fishnft.xyz/koi/nft/KOIEarlySupporterNFT/";

    constructor() ERC721("KOI Early Supporter NFT", "KOIEarlySupporterNFT") {}

    function contractURI() public view returns (string memory) {
        return string(abi.encodePacked(_baseURI(), "contract"));
    }

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );

        return
            string(
                abi.encodePacked(
                    _baseURI(),
                    Strings.toString(tokenId)
                )
            );
    }

    function list(address account) external view override returns(uint256[] memory tokenIds, uint8[] memory typeIds){
        uint256 length = balanceOf(account);
        tokenIds = new uint256[](length);
        typeIds = new uint8[](length);

        for(uint256 i=0; i < length; i++){
            uint256 tokenId = tokenOfOwnerByIndex(account, i);
            tokenIds[i] = tokenId;
            typeIds[i] = typeId[tokenId];
        }
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return __baseURI;
    }

    function mint(address owner, uint8 typeId_) public onlyAdmin returns (uint256) {
        uint256 newItemId = nextId;
        nextId++;
        _mint(owner, newItemId);
        typeId[newItemId] = typeId_; 
        return newItemId;
    }

    function updateBaseURI(string memory uri) external onlyAdmin {
        __baseURI = uri;
    }
}
