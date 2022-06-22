// //SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./IMarket.sol";
import "../owner/Treasury.sol";
import "../tokens/Fish.sol";

// import "hardhat/console.sol";

contract Market1 is IMarket, Treasury, IERC721Receiver {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using Address for address;
    using EnumerableSet for EnumerableSet.UintSet;

    struct SellOrderData {
        uint32 createdAt;
        address seller;
        address coin;
        uint256 price;
    }

    uint256 public override feeRate; // * 10000
    address public override nft;

    mapping(uint256 => SellOrderData) public orderMap; //tokenId: orderData
    EnumerableSet.UintSet internal orderTokenIdSet;
    mapping(address => EnumerableSet.UintSet) internal userTokenMap; //user: [tokenId, tokenId]

    constructor(
        uint32 startTime_,
        uint32 endTime_,
        address treasury_,
        address nft_,
        uint256 feeRate_
    ) Treasury("Market1", startTime_, endTime_, treasury_) {
        nft = nft_;
        feeRate = feeRate_;
    }

    function getFee(uint256 price) public view returns (uint256) {
        return price.mul(feeRate).div(10000);
    }

    function getOrder(uint256 tokenId)
        external
        view
        override
        returns (SellOrder memory)
    {
        require(orderTokenIdSet.contains(tokenId), "Order does not exist");
        SellOrder memory order = SellOrder(
            tokenId,
            orderMap[tokenId].createdAt,
            orderMap[tokenId].seller,
            orderMap[tokenId].coin,
            orderMap[tokenId].price
        );

        return order;
    }

    function orderList(uint256 limit, uint256 offset)
        external
        view
        override
        returns (SellOrder[] memory)
    {
        if (offset >= orderTokenIdSet.length()) {
            return new SellOrder[](0);
        }
        if (limit > orderTokenIdSet.length() - offset) {
            limit = orderTokenIdSet.length() - offset;
        }

        SellOrder[] memory orderLs = new SellOrder[](limit);
        for (uint256 i = 0; i < limit; i++) {
            uint256 tokenId = orderTokenIdSet.at(i + offset);
            orderLs[i].tokenId = tokenId;
            orderLs[i].createdAt = orderMap[tokenId].createdAt;
            orderLs[i].seller = orderMap[tokenId].seller;
            orderLs[i].coin = orderMap[tokenId].coin;
            orderLs[i].price = orderMap[tokenId].price;
        }

        return orderLs;
    }

    function userOrderList(
        address account,
        uint256 limit,
        uint256 offset
    ) external view override returns (SellOrder[] memory) {
        if (offset >= userTokenMap[account].length()) {
            return new SellOrder[](0);
        }
        if (limit > userTokenMap[account].length() - offset) {
            limit = userTokenMap[account].length() - offset;
        }

        SellOrder[] memory orderLs = new SellOrder[](limit);
        for (uint256 i = 0; i < limit; i++) {
            uint256 tokenId = userTokenMap[account].at(i + offset);
            orderLs[i].tokenId = tokenId;
            orderLs[i].createdAt = orderMap[tokenId].createdAt;
            orderLs[i].seller = orderMap[tokenId].seller;
            orderLs[i].coin = orderMap[tokenId].coin;
            orderLs[i].price = orderMap[tokenId].price;
        }

        return orderLs;
    }

    function query(
        address seller, // 0 = null
        address coin, // 0 = eth bnb
        uint256 minPrice,
        uint256 maxPrice, // 0 = null
        uint256 limit,
        uint256 offset
    ) external view override returns (SellOrder[] memory) {
        uint256 length = orderTokenIdSet.length();
        require(offset < length);
        if (limit > length - offset) {
            limit = length - offset;
        }

        SellOrder[] memory orderArray = new SellOrder[](limit);
        uint256 num = 0;
        for (uint256 i = 0; i < length; i++) {
            uint256 tokenId = orderTokenIdSet.at(i);
            if (
                (seller == address(0) || seller == orderMap[tokenId].seller) &&
                (coin == orderMap[tokenId].coin) &&
                (minPrice <= orderMap[tokenId].price) &&
                (maxPrice == 0 || maxPrice >= orderMap[tokenId].price)
            ) {
                if (num >= limit) {
                    break;
                }
                if (num >= offset) {
                    orderArray[i].tokenId = tokenId;
                    orderArray[i].createdAt = orderMap[tokenId].createdAt;
                    orderArray[i].seller = orderMap[tokenId].seller;
                    orderArray[i].coin = orderMap[tokenId].coin;
                    orderArray[i].price = orderMap[tokenId].price;
                }
                num++;
            }
        }
        return orderArray;
    }

    modifier isNotOrderOwner(uint256 tokenId) {
        require(orderTokenIdSet.contains(tokenId), "Order does not exist");
        require(
            orderMap[tokenId].seller != msg.sender,
            "You can't buy your own NFT"
        );
        _;
    }

    modifier isOrderOwner(uint256 tokenId) {
        require(orderTokenIdSet.contains(tokenId), "Order does not exist");
        require(
            orderMap[tokenId].seller == msg.sender,
            "This order does not belong to you"
        );
        _;
    }

    function sell(
        uint256 tokenId,
        address coin,
        uint256 price
    ) external override checkTime {
        // require(IERC721(nft).getApproved(tokenId) == address(this));
        IERC721(nft).safeTransferFrom(msg.sender, address(this), tokenId);

        orderMap[tokenId].createdAt = uint32(block.timestamp);
        orderMap[tokenId].seller = msg.sender;
        orderMap[tokenId].coin = coin;
        orderMap[tokenId].price = price;

        orderTokenIdSet.add(tokenId);
        userTokenMap[msg.sender].add(tokenId);

        emit Sell(tokenId, msg.sender, coin, price);
    }

    function cancel(uint256 tokenId)
        external
        override
        checkTime
        isOrderOwner(tokenId)
    {
        IERC721(nft).safeTransferFrom(address(this), msg.sender, tokenId);
        orderTokenIdSet.remove(tokenId);
        delete orderMap[tokenId];
        userTokenMap[msg.sender].remove(tokenId);
        emit Cancel(tokenId, msg.sender);
    }

    function update(
        uint256 tokenId,
        address coin,
        uint256 price
    ) external override checkTime isOrderOwner(tokenId) {
        orderMap[tokenId].coin = coin;
        orderMap[tokenId].price = price;
        emit Update(tokenId, msg.sender, coin, price);
    }

    function buyWithETH(uint256 tokenId)
        external
        payable
        override
        checkTime
        isNotOrderOwner(tokenId)
    {
        address seller = orderMap[tokenId].seller;
        address coin = orderMap[tokenId].coin;
        uint256 price = orderMap[tokenId].price;

        require(coin == address(0), "coin err");
        require(msg.value == price, "Insufficient Balance");

        uint256 fee = getFee(price);

        payable(treasury).transfer(fee);
        payable(seller).transfer(price.sub(fee));

        IERC721(nft).safeTransferFrom(address(this), msg.sender, tokenId);

        orderTokenIdSet.remove(tokenId);
        userTokenMap[seller].remove(tokenId);

        emit Buy(tokenId, seller, msg.sender, coin, price, fee);
    }

    function buyWithERC20(uint256 tokenId)
        external
        virtual
        override
        checkTime
        isNotOrderOwner(tokenId)
    {
        address seller = orderMap[tokenId].seller;
        address coin = orderMap[tokenId].coin;
        uint256 price = orderMap[tokenId].price;
        uint256 fee = getFee(price);

        IERC20(coin).safeTransferFrom(msg.sender, seller, price.sub(fee));
        IERC20(coin).safeTransferFrom(msg.sender, treasury, fee);

        IERC721(nft).safeTransferFrom(address(this), msg.sender, tokenId);

        orderTokenIdSet.remove(tokenId);
        userTokenMap[seller].remove(tokenId);

        emit Buy(tokenId, seller, msg.sender, coin, price, fee);
    }

    function setNFT(address nft_) external onlyAdmin {
        nft = nft_;
    }

    function setFeeRate(uint256 feeRate_) external onlyAdmin {
        feeRate = feeRate_;
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
