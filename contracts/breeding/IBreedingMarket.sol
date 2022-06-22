// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IBreedingMarket {
    struct BreedingOrder {
        uint256 tokenId;
        uint32 createdAt;
        address seller;
        address coin;
        uint256 price;
        uint256 breedingTimes;
    }

    function nft() external view returns (address);

    function shell() external view returns (address);

    function getBreedingFee(uint256 fatherId, uint256 motherId)
        external
        view
        returns (uint256 fee);

    function marketFeeRate() external view returns (uint256); // * 10000

    function getOrder(uint256 tokenId)
        external
        view
        returns (BreedingOrder memory);

    function orderList(uint256 limit, uint256 offset)
        external
        view
        returns (BreedingOrder[] memory);

    function userOrderList(
        address account,
        uint256 limit,
        uint256 offset
    ) external view returns (BreedingOrder[] memory);

    function query(
        address seller, // 0 = null
        address coin, // 0 = eth bnb
        uint256 minPrice,
        uint256 maxPrice,
        uint256 limit,
        uint256 offset
    ) external view returns (BreedingOrder[] memory);

    function sell(
        uint256 tokenId,
        address coin,
        uint256 price,
        uint256 breedingTimes
    ) external;

    function cancel(uint256 tokenId) external;

    function update(
        uint256 tokenId,
        address coin,
        uint256 price,
        uint256 breedingTimes
    ) external;

    function breedingWithETH(uint256 marketTokenId, uint256 userTokenId)
        external
        payable;

    function breedingWithERC20(uint256 marketTokenId, uint256 userTokenId)
        external;

    event Sell(uint256 tokenId, address seller, address coin, uint256 price, uint256 breedingTimes);

    event Cancel(uint256 tokenId, address seller);

    event Over(uint256 tokenId, address seller);

    event Update(
        uint256 tokenId,
        address seller,
        address coin,
        uint256 price,
        uint256 breedingTimes
    );

    event MarketBreeding(
        uint256 marketTokenId,
        uint256 userTokenId,
        uint256 childTokenId,
        uint256 childGene,
        address seller,
        address buyer,
        address coin,
        uint256 price,
        uint256 marketFee,
        uint256 breedingFee
    );
}
