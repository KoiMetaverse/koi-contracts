//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

interface IMarket {
    struct SellOrder {
        uint256 tokenId;
        uint32 createdAt;
        address seller;
        address coin;
        uint256 price;
    }

    function nft() external view returns (address);

    function feeRate() external view returns (uint256); // * 10000

    function getOrder(uint256 tokenId) external view returns (SellOrder memory);

    function orderList(uint256 limit, uint256 offset)
        external
        view
        returns (SellOrder[] memory);

    function userOrderList(address account, uint256 limit, uint256 offset)
        external
        view
        returns (SellOrder[] memory);

    function query(
        address seller, // 0 = null
        address coin, // 0 = eth bnb
        uint256 minPrice,
        uint256 maxPrice,
        uint256 limit, 
        uint256 offset
    ) external view returns (SellOrder[] memory);

    function sell(
        uint256 tokenId,
        address coin,
        uint256 price
    ) external;

    function cancel(uint256 tokenId) external;

    function update(
        uint256 tokenId,
        address coin,
        uint256 price
    ) external;

    function buyWithETH(uint256 tokenId) external payable;

    function buyWithERC20(uint256 tokenId) external;

    event Sell(uint256 tokenId, address seller, address coin, uint256 price);

    event Cancel(uint256 tokenId, address seller);

    event Update(uint256 tokenId, address seller, address coin, uint256 price);

    event Buy(
        uint256 tokenId,
        address seller,
        address buyer,
        address coin,
        uint256 price,
        uint256 fee
    );
}
