// //SPDX-License-Identifier: Unlicense
// pragma solidity ^0.8.0;
// import "@openzeppelin/contracts/utils/math/SafeMath.sol";
// import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
// import "@openzeppelin/contracts/utils/Address.sol";
// import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
// import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
// import "./IMarket.sol";
// import "../owner/Treasury.sol";
// // import "hardhat/console.sol";

// contract Market0 is IMarket, Treasury {
//     using SafeMath for uint256;
//     using SafeERC20 for IERC20;
//     using Address for address;
//     using EnumerableSet for EnumerableSet.UintSet;

//     struct SellOrderData {
//         uint32 createdAt;
//         address seller;
//         address coin;
//         uint256 price;
//     }

//     uint256 public override feeRate; // * 10000
//     address public override nft;

//     mapping(uint256 => SellOrderData) public orderMap; //tokenId: orderData
//     EnumerableSet.UintSet internal orderTokenIdSet;

//     constructor(
//         string memory name_,
//         address nft_,
//         uint256 feeRate_,
//         uint32 startTime_,
//         uint32 endTime_,
//         address treasury_
//     ) Treasury(name_, startTime_, endTime_, treasury_) {
//         nft = nft_;
//         feeRate = feeRate_;
//     }

//     function getFee(uint256 price) public view returns (uint256) {
//         return price.mul(feeRate).div(10000);
//     }

//     function getOrder(uint256 tokenId)
//         external
//         view
//         override
//         returns (SellOrder memory)
//     {
//         require(orderTokenIdSet.contains(tokenId), "Order does not exist");
//         SellOrder memory order = SellOrder(
//             tokenId,
//             orderMap[tokenId].createdAt,
//             orderMap[tokenId].seller,
//             orderMap[tokenId].coin,
//             orderMap[tokenId].price
//         );

//         return order;
//     }

//     function orderList(uint256 limit, uint256 offset)
//         external
//         view
//         override
//         returns (SellOrder[] memory)
//     {
//         require(offset < orderTokenIdSet.length());
//         if (limit > orderTokenIdSet.length() - offset) {
//             limit = orderTokenIdSet.length() - offset;
//         }

//         SellOrder[] memory orderLs = new SellOrder[](limit);
//         for (uint256 i = 0; i < limit; i++) {
//             uint256 tokenId = orderTokenIdSet.at(i + offset);
//             orderLs[i].tokenId = tokenId;
//             orderLs[i].createdAt = orderMap[tokenId].createdAt;
//             orderLs[i].seller = orderMap[tokenId].seller;
//             orderLs[i].coin = orderMap[tokenId].coin;
//             orderLs[i].price = orderMap[tokenId].price;
//         }

//         return orderLs;
//     }

//     function query(
//         address seller, // 0 = null
//         address coin, // 0 = eth bnb
//         uint256 minPrice,
//         uint256 maxPrice, // 0 = null
//         uint256 startCreatedAt,
//         uint256 endCreatedAt
//     ) external view override returns (SellOrder[] memory) {
//         uint256 limit = 20;
//         SellOrder[] memory orderArray = new SellOrder[](limit);
//         for (uint256 i = 0; i < limit; i++) {
//             uint256 tokenId = orderTokenIdSet.at(i);
//             uint32 orderCreatedAt = orderMap[tokenId].createdAt;
//             address orderSeller = orderMap[tokenId].seller;
//             address orderCoin = orderMap[tokenId].coin;
//             uint256 orderPrice = orderMap[tokenId].price;

//             if (
//                 (seller == address(0) || seller == orderSeller) &&
//                 (coin == orderCoin) &&
//                 (minPrice <= orderPrice) &&
//                 (maxPrice == 0 || maxPrice >= orderPrice) &&
//                 (startCreatedAt <= orderCreatedAt) &&
//                 (endCreatedAt >= orderCreatedAt)
//             ) {
//                 orderArray[i].tokenId = tokenId;
//                 orderArray[i].createdAt = orderCreatedAt;
//                 orderArray[i].seller = orderSeller;
//                 orderArray[i].coin = orderCoin;
//                 orderArray[i].price = orderPrice;
//             }
//         }
//         return orderArray;
//     }

//     modifier isNotOrderOwner(uint256 tokenId) {
//         require(orderTokenIdSet.contains(tokenId), "Order does not exist");
//         require(
//             orderMap[tokenId].seller != msg.sender,
//             "You can't buy your own NFT"
//         );
//         require(
//             IERC721(nft).getApproved(tokenId) == address(this),
//             "Not approved"
//         );
//         _;
//     }

//     modifier isOrderOwner(uint256 tokenId) {
//         require(orderTokenIdSet.contains(tokenId), "Order does not exist");
//         require(
//             orderMap[tokenId].seller == msg.sender,
//             "This order does not belong to you"
//         );
//         require(
//             IERC721(nft).getApproved(tokenId) == address(this),
//             "Not approved"
//         );
//         _;
//     }

//     function sell(
//         uint256 tokenId,
//         address coin,
//         uint256 price
//     ) external override checkTime {
//         require(IERC721(nft).getApproved(tokenId) == address(this));

//         orderMap[tokenId].createdAt = uint32(block.timestamp);
//         orderMap[tokenId].seller = msg.sender;
//         orderMap[tokenId].coin = coin;
//         orderMap[tokenId].price = price;
//         orderTokenIdSet.add(tokenId);

//         emit Sell(tokenId, msg.sender, coin, price);
//     }

//     function cancel(uint256 tokenId)
//         external
//         override
//         checkTime
//         isOrderOwner(tokenId)
//     {
//         orderTokenIdSet.remove(tokenId);
//         delete orderMap[tokenId];
//         emit Cancel(tokenId, msg.sender);
//     }

//     function update(
//         uint256 tokenId,
//         address coin,
//         uint256 price
//     ) external override checkTime isOrderOwner(tokenId) {
//         orderMap[tokenId].coin = coin;
//         orderMap[tokenId].price = price;
//         emit Update(tokenId, msg.sender, coin, price);
//     }

//     function buyWithETH(uint256 tokenId)
//         external
//         payable
//         override
//         checkTime
//         isNotOrderOwner(tokenId)
//     {
//         address seller = orderMap[tokenId].seller;
//         address coin = orderMap[tokenId].coin;
//         uint256 price = orderMap[tokenId].price;

//         require(coin == address(0), "coin err");
//         require(msg.value == price, "Insufficient Balance");

//         uint256 fee = getFee(price);

//         payable(treasury).transfer(fee);
//         payable(seller).transfer(price.sub(fee));

//         IERC721(nft).safeTransferFrom(seller, msg.sender, tokenId);

//         emit Buy(tokenId, seller, msg.sender, coin, price, fee);
//     }

//     function buyWithERC20(uint256 tokenId)
//         external
//         override
//         checkTime
//         isNotOrderOwner(tokenId)
//     {
//         address seller = orderMap[tokenId].seller;
//         address coin = orderMap[tokenId].coin;
//         uint256 price = orderMap[tokenId].price;
//         uint256 fee = getFee(price);

//         IERC20(coin).safeTransferFrom(msg.sender, seller, price.sub(fee));
//         IERC20(coin).safeTransferFrom(msg.sender, treasury, fee);

//         IERC721(nft).safeTransferFrom(seller, msg.sender, tokenId);

//         emit Buy(tokenId, seller, msg.sender, coin, price, fee);
//     }

//     function setNFT(address nft_) external onlyAdmin {
//         nft = nft_;
//     }

//     function setFeeRate(uint256 feeRate_) external onlyAdmin {
//         feeRate = feeRate_;
//     }
// }
