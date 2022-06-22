// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./IBreedingMarket.sol";
import "../owner/Treasury.sol";
import "../tokens/Token.sol";
import "../tokens/Fish.sol";
import "../tokens/IFishStatus.sol";
import "../tokens/FishGene.sol";
import "../shellmining/IShellMining.sol";

contract BreedingMarket is IBreedingMarket, Treasury, IERC721Receiver {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using Address for address;
    using EnumerableSet for EnumerableSet.UintSet;

    struct BreedingOrderData {
        uint32 createdAt;
        address seller;
        address coin;
        uint256 price;
        uint256 breedingTimes;
    }

    Fish public fish;
    IFishStatus public fishStatus;
    FishGene public fishGene;
    address public override shell;
    IShellMining public pool;

    uint256 public K = 500 * 10**18;

    uint256 public override marketFeeRate; // * 10000

    mapping(uint256 => BreedingOrderData) public orderMap; //tokenId: orderData
    EnumerableSet.UintSet internal orderTokenIdSet;
    mapping(address => EnumerableSet.UintSet) internal userTokenMap; //user: [tokenId, tokenId]

    constructor(
        uint32 startTime_,
        uint32 endTime_,
        address treasury_,
        address nft_,
        address fishStatus_,
        address fishGene_,
        address shell_,
        address pool_
    ) Treasury("BreedingMarket", startTime_, endTime_, treasury_) {
        fish = Fish(nft_);
        fishStatus = IFishStatus(fishStatus_);
        fishGene = FishGene(fishGene_);
        shell = shell_;
        pool = IShellMining(pool_);
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

    function availableBreedingTimes(uint256 tokenId)
        public
        view
        returns (uint256)
    {
        uint256 total = fish.gene(tokenId) % 1000;
        return total.sub(fishStatus.breedingTimes(tokenId));
    }

    function nft() external view override returns (address) {
        return address(fish);
    }

    function getMarketFee(uint256 price) public view returns (uint256) {
        return price.mul(marketFeeRate).div(10000);
    }

    function getBreedingFee(uint256 fatherId, uint256 motherId)
        public
        view
        override
        returns (uint256)
    {
        uint256 total0 = fish.gene(fatherId) % 1000;
        uint256 breedingTimes0 = fishStatus.breedingTimes(fatherId);
        require(total0 > breedingTimes0, "This fish can no longer reproduce");

        uint256 total1 = fish.gene(motherId) % 1000;
        uint256 breedingTimes1 = fishStatus.breedingTimes(motherId);
        require(total1 > breedingTimes1, "This fish can no longer reproduce");

        uint256 fatherPower = fishStatus.power(fatherId);
        uint256 motherPower = fishStatus.power(motherId);
        uint256 fee = (((fatherPower + motherPower) / 2) * K) / getAP();

        fee += fee.mul(breedingTimes0 + breedingTimes1).mul(15).div(100);
        return fee;
    }

    function getAP() public view returns (uint256) {
        uint256 totalNft = pool.totalNft();
        uint256 totalFishOriginalPower = pool.totalFishOriginalPower();
        if (totalNft == 0 || totalFishOriginalPower == 0) {
            return 100;
        }
        return totalFishOriginalPower / totalNft;
    }

    function getOrder(uint256 tokenId)
        external
        view
        override
        returns (BreedingOrder memory)
    {
        require(orderTokenIdSet.contains(tokenId), "Order does not exist");
        BreedingOrder memory order = BreedingOrder(
            tokenId,
            orderMap[tokenId].createdAt,
            orderMap[tokenId].seller,
            orderMap[tokenId].coin,
            orderMap[tokenId].price,
            orderMap[tokenId].breedingTimes
        );

        return order;
    }

    function orderList(uint256 limit, uint256 offset)
        external
        view
        override
        returns (BreedingOrder[] memory)
    {
        if (offset >= orderTokenIdSet.length()) {
            return new BreedingOrder[](0);
        }
        if (limit > orderTokenIdSet.length() - offset) {
            limit = orderTokenIdSet.length() - offset;
        }

        BreedingOrder[] memory orderLs = new BreedingOrder[](limit);
        for (uint256 i = 0; i < limit; i++) {
            uint256 tokenId = orderTokenIdSet.at(i + offset);
            orderLs[i].tokenId = tokenId;
            orderLs[i].createdAt = orderMap[tokenId].createdAt;
            orderLs[i].seller = orderMap[tokenId].seller;
            orderLs[i].coin = orderMap[tokenId].coin;
            orderLs[i].price = orderMap[tokenId].price;
            orderLs[i].breedingTimes = orderMap[tokenId].breedingTimes;
        }

        return orderLs;
    }

    function userOrderList(
        address account,
        uint256 limit,
        uint256 offset
    ) external view override returns (BreedingOrder[] memory) {
        if (offset >= userTokenMap[account].length()) {
            return new BreedingOrder[](0);
        }
        if (limit > userTokenMap[account].length() - offset) {
            limit = userTokenMap[account].length() - offset;
        }

        BreedingOrder[] memory orderLs = new BreedingOrder[](limit);
        for (uint256 i = 0; i < limit; i++) {
            uint256 tokenId = userTokenMap[account].at(i + offset);
            orderLs[i].tokenId = tokenId;
            orderLs[i].createdAt = orderMap[tokenId].createdAt;
            orderLs[i].seller = orderMap[tokenId].seller;
            orderLs[i].coin = orderMap[tokenId].coin;
            orderLs[i].price = orderMap[tokenId].price;
            orderLs[i].breedingTimes = orderMap[tokenId].breedingTimes;
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
    ) external view override returns (BreedingOrder[] memory) {
        uint256 length = orderTokenIdSet.length();
        require(offset < length);
        if (limit > length - offset) {
            limit = length - offset;
        }

        BreedingOrder[] memory orderArray = new BreedingOrder[](limit);
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
                    orderArray[i].breedingTimes = orderMap[tokenId]
                        .breedingTimes;
                }
                num++;
            }
        }
        return orderArray;
    }

    function sell(
        uint256 tokenId,
        address coin,
        uint256 price,
        uint256 breedingTimes
    ) external override checkTime {
        require(
            price > 0 &&
                breedingTimes > 0 &&
                breedingTimes <= availableBreedingTimes(tokenId),
            "Parameter error"
        );

        fish.safeTransferFrom(msg.sender, address(this), tokenId);

        orderMap[tokenId].createdAt = uint32(block.timestamp);
        orderMap[tokenId].seller = msg.sender;
        orderMap[tokenId].coin = coin;
        orderMap[tokenId].price = price;
        orderMap[tokenId].breedingTimes = breedingTimes;

        orderTokenIdSet.add(tokenId);
        userTokenMap[msg.sender].add(tokenId);

        emit Sell(tokenId, msg.sender, coin, price, breedingTimes);
    }

    function cancel(uint256 tokenId)
        external
        override
        checkTime
        isOrderOwner(tokenId)
    {
        fish.safeTransferFrom(address(this), msg.sender, tokenId);
        orderTokenIdSet.remove(tokenId);
        delete orderMap[tokenId];
        userTokenMap[msg.sender].remove(tokenId);
        emit Cancel(tokenId, msg.sender);
    }

    function update(
        uint256 tokenId,
        address coin,
        uint256 price,
        uint256 breedingTimes
    ) external override checkTime isOrderOwner(tokenId) {
        require(
            price > 0 &&
                breedingTimes > 0 &&
                breedingTimes <= availableBreedingTimes(tokenId),
            "Parameter error"
        );

        orderMap[tokenId].coin = coin;
        orderMap[tokenId].price = price;
        orderMap[tokenId].breedingTimes = breedingTimes;
        emit Update(tokenId, msg.sender, coin, price, breedingTimes);
    }

    function checkOrderOver(uint256 tokenId) internal {
        if (orderMap[tokenId].breedingTimes == 0) {
            address seller = orderMap[tokenId].seller;
            fish.safeTransferFrom(address(this), seller, tokenId);
            orderTokenIdSet.remove(tokenId);
            delete orderMap[tokenId];
            userTokenMap[seller].remove(tokenId);
            emit Over(tokenId, seller);
        }
    }

    function breeding(uint256 marketTokenId, uint256 userTokenId)
        internal
        returns (
            uint256 childTokenId,
            uint256 childGene,
            uint256 breedingFee
        )
    {
        breedingFee = getBreedingFee(marketTokenId, userTokenId);
        SHELL(shell).burnFrom(msg.sender, breedingFee);

        uint256 gene0 = fish.gene(marketTokenId);
        uint256 gene1 = fish.gene(userTokenId);
        childGene = fishGene.newGene(gene0, gene1);

        childTokenId = fish.mint(msg.sender, childGene);

        fishStatus.breedingTimesAdd(marketTokenId);
        fishStatus.breedingTimesAdd(userTokenId);
    }

    function breedingWithETH(uint256 marketTokenId, uint256 userTokenId)
        external
        payable
        override
        checkTime
    {
        require(
            fish.ownerOf(marketTokenId) == address(this) &&
                fish.ownerOf(userTokenId) == msg.sender,
            "You are not the owner of fish"
        );
        require(
            availableBreedingTimes(userTokenId) > 0,
            "This fish can no longer reproduce"
        );

        address seller = orderMap[marketTokenId].seller;
        address coin = orderMap[marketTokenId].coin;
        uint256 price = orderMap[marketTokenId].price;

        require(coin == address(0), "coin err");
        require(msg.value == price, "Insufficient Balance");

        uint256 marketFee = getMarketFee(price);

        payable(treasury).transfer(marketFee);
        payable(seller).transfer(price.sub(marketFee));

        (
            uint256 childTokenId,
            uint256 childGene,
            uint256 breedingFee
        ) = breeding(marketTokenId, userTokenId);

        emit MarketBreeding(
            marketTokenId,
            userTokenId,
            childTokenId,
            childGene,
            seller,
            msg.sender,
            coin,
            price,
            marketFee,
            breedingFee
        );

        orderMap[marketTokenId].breedingTimes--;
        checkOrderOver(marketTokenId);
    }

    function breedingWithERC20(uint256 marketTokenId, uint256 userTokenId)
        external
        override
        checkTime
    {
        require(
            fish.ownerOf(marketTokenId) == address(this) &&
                fish.ownerOf(userTokenId) == msg.sender,
            "You are not the owner of fish"
        );
        require(
            availableBreedingTimes(userTokenId) > 0,
            "This fish can no longer reproduce"
        );

        address seller = orderMap[marketTokenId].seller;
        address coin = orderMap[marketTokenId].coin;
        uint256 price = orderMap[marketTokenId].price;
        uint256 marketFee = getMarketFee(price);

        IERC20(coin).safeTransferFrom(msg.sender, seller, price.sub(marketFee));
        IERC20(coin).safeTransferFrom(msg.sender, treasury, marketFee);

        (
            uint256 childTokenId,
            uint256 childGene,
            uint256 breedingFee
        ) = breeding(marketTokenId, userTokenId);

        emit MarketBreeding(
            marketTokenId,
            userTokenId,
            childTokenId,
            childGene,
            seller,
            msg.sender,
            coin,
            price,
            marketFee,
            breedingFee
        );

        orderMap[marketTokenId].breedingTimes--;
        checkOrderOver(marketTokenId);
    }

    function setFish(address fish_) external onlyAdmin {
        fish = Fish(fish_);
    }

    function setFishStatus(address fishStatus_) external onlyAdmin {
        fishStatus = IFishStatus(fishStatus_);
    }

    function setShell(address shell_) external onlyAdmin {
        shell = shell_;
    }

    function setPool(address pool_) external onlyAdmin {
        pool = IShellMining(pool_);
    }

    function setFishGene(address fishGene_) external onlyAdmin {
        fishGene = FishGene(fishGene_);
    }

    function setK(uint256 k_) external onlyAdmin {
        K = k_;
    }

    function setMarketFeeRate(uint256 feeRate_) external onlyAdmin {
        marketFeeRate = feeRate_;
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
