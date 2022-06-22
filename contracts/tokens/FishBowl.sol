//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "../owner/AdminRole.sol";
import "./IFishBowl.sol";

contract FishBowl is IFishBowl, ERC721Enumerable, AdminRole{
  using Strings for uint256;
  
  struct FishBowlInfo {
    uint8 capacity;
  }

  uint256 public nextId;

  string private __baseURI = "http://statics.fishnft.xyz/512/";

  mapping (uint256 => FishBowlInfo) private _fishBowlInfoMap;

  constructor() ERC721("fishbowl nft", "FISHBOWL") {}

  function capacity(uint256 tokenId) public view override returns(uint8){
    return _fishBowlInfoMap[tokenId].capacity;
  }

  function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
    require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

    string memory baseURI = _baseURI();
    
    return bytes(baseURI).length > 0
        ? string(abi.encodePacked(baseURI, tokenId, ".png"))
        : '';
  }

  function _baseURI() internal view virtual override returns (string memory) {
    return __baseURI;
  }

  function mint(address owner, uint8 _capacity) public onlyAdmin returns(uint256){
    uint256 newItemId = nextId;
    nextId++;

    _mint(owner, newItemId);
    _fishBowlInfoMap[newItemId].capacity = _capacity;
    return newItemId;
  }

  function updateBaseURI(string memory uri) external onlyAdmin {
    __baseURI = uri;
  }
}
