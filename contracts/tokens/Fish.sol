//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "../owner/AdminRole.sol";
import "./IFish.sol";

contract Fish is IFish, ERC721Enumerable, AdminRole {
    struct FishInfo {
        uint256 gene;
        uint32 birthday;
    }

    uint256 public nextId;

    string private __baseURI = "http://metadata.fishnft.xyz/koi/nft/fish/";

    mapping(uint256 => FishInfo) private _fishInfoMap;

    constructor() ERC721("Koi Metaverse", "KOI") {}

    function fishInfo(uint256 tokenId)
        public
        view
        override
        returns (
            uint256 gene_,
            uint32 birthday_
        )
    {
        FishInfo memory info = _fishInfoMap[tokenId];
        gene_ = info.gene;
        birthday_ = info.birthday;

        require(birthday_ != 0, "Fish does not exist");
    }

    function fishIdList(address account) external view override returns(uint256[] memory){
        uint256 length = balanceOf(account);
        uint256[] memory tokenIds = new uint256[](length);

        for(uint256 i=0; i < length; i++){
            tokenIds[i] = tokenOfOwnerByIndex(account, i);
        }
        return tokenIds;
    }

    function gene(uint256 tokenId) public view override returns (uint256) {
        return _fishInfoMap[tokenId].gene;
    }

    function birthday(uint256 tokenId) public view override returns (uint32) {
        return _fishInfoMap[tokenId].birthday;
    }

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
                    Strings.toString(gene(tokenId)),
                    "/",
                    Strings.toString(tokenId)
                )
            );
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return __baseURI;
    }

    function mint(
        address owner,
        uint256 gene_
    ) public onlyAdmin returns (uint256) {
        uint256 newItemId = nextId;
        nextId++;

        _mint(owner, newItemId);

        _fishInfoMap[newItemId].gene = gene_;
        _fishInfoMap[newItemId].birthday = uint32(block.timestamp);

        return newItemId;
    }

    function updateBaseURI(string memory uri) external onlyAdmin {
        __baseURI = uri;
    }
}
