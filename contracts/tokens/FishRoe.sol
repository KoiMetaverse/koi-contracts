//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "../owner/AdminRole.sol";
import "./IFishRoe.sol";

contract FishRoe is IFishRoe, ERC721Enumerable, AdminRole {
    using Strings for uint256;

    struct FishRoeInfo {
        uint8 colour;
        uint8 suit;
    }

    uint256 public nextId;

    string private __baseURI = "http://metadata.fishnft.xyz/koi/nft/fishroe/";

    mapping(uint256 => FishRoeInfo) private _fishRoeInfoMap;

    constructor() ERC721("Koiverse fish roe NFT", "FISHROE") {}

    function fishRoeInfo(uint256 tokenId)
        public
        view
        override
        returns (
            uint8 colour_,
            uint8 suit_
        )
    {
        FishRoeInfo memory info = _fishRoeInfoMap[tokenId];
        colour_ = info.colour;
        suit_ = info.suit;
    }

    function colour(uint256 tokenId) public view override returns (uint8) {
        return _fishRoeInfoMap[tokenId].colour;
    }

    function suit(uint256 tokenId) public view override returns (uint8) {
        return _fishRoeInfoMap[tokenId].suit;
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

        string memory baseURI = _baseURI();

        return
            bytes(baseURI).length > 0
                ? string(abi.encodePacked(baseURI, "/", tokenId))
                : "";
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return __baseURI;
    }

    function mint(
        address owner,
        uint8 colour_,
        uint8 suit_
    ) public onlyAdmin returns (uint256) {
        uint256 newItemId = nextId;
        nextId++;

        _mint(owner, newItemId);

        _fishRoeInfoMap[newItemId].colour = colour_;
        _fishRoeInfoMap[newItemId].suit = suit_;
        return newItemId;
    }

    function updateBaseURI(string memory uri) external onlyAdmin {
        __baseURI = uri;
    }
}
