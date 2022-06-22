//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./IFishGeneBank.sol";
import "./IBlindBox.sol";
import "../tokens/Fish.sol";
import "../owner/AdminRole.sol";

contract BlindBox is IBlindBox, AdminRole {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using Address for address;

    string public override name;
    address public override nft;
    address public override coin;
    uint256 public override price;
    uint256 public override total;
    uint256 public override remain;
    uint256 public override limit;
    uint256 public override startTime;
    uint256 public override endTime;
    mapping(address => uint8) public override buyCount;
    IFishGeneBank public fishGeneBank;

    address payable private treasury;

    constructor(
        string memory name_,
        address nft_,
        address coin_,
        uint256 price_,
        uint256 total_,
        uint256 limit_,
        uint256 startTime_,
        uint256 endTime_,
        address fishGeneBank_
    ) {
        name = name_;
        nft = nft_;
        coin = coin_;
        price = price_;
        total = total_;
        remain = total_;
        limit = limit_;
        startTime = startTime_;
        endTime = endTime_;
        fishGeneBank = IFishGeneBank(fishGeneBank_);
        treasury = payable(msg.sender);
    }

    function info()
        external
        view
        override
        returns (
            string memory name_,
            address nft_,
            address coin_,
            uint256 price_,
            uint256 total_,
            uint256 remain_,
            uint256 limit_,
            uint256 startTime_,
            uint256 endTime_
        )
    {
        name_ = name;
        nft_ = nft;
        coin_ = coin;
        price_ = price;
        total_ = total;
        remain_ = remain;
        limit_ = limit;
        startTime_ = startTime;
        endTime_ = endTime;
    }

    function buy(uint8 count) external virtual override {
        require(
            block.timestamp >= startTime && block.timestamp < endTime,
            "Non business hours"
        );
        require(remain > 0, "It's sold out");
        require(
            count > 0 && count <= limit - buyCount[msg.sender],
            "It's sold out"
        );

        IERC20(coin).safeTransferFrom(msg.sender, treasury, price * count);

        uint256[] memory tokenIdList = new uint256[](count);
        
        uint256[] memory geneList = fishGeneBank.getGenes(count);

        for (uint8 i = 0; i < count; i++) {            
            tokenIdList[i] = Fish(nft).mint(msg.sender, geneList[i]);
        }

        remain = remain.sub(count);
        buyCount[msg.sender] += count;

        emit Buy(msg.sender, tokenIdList, geneList);
    }

    function buyEth(uint8 count) external override payable {
        require(
            block.timestamp >= startTime && block.timestamp < endTime,
            "Non business hours"
        );
        require(remain > 0, "It's sold out");
        require(
            count > 0 && count <= limit - buyCount[msg.sender],
            "It's sold out"
        );

        require(msg.value == price * count, "Insufficient Balance");
        treasury.transfer(price * count);

        uint256[] memory tokenIdList = new uint256[](count);
        
        uint256[] memory geneList = fishGeneBank.getGenes(count);

        for (uint8 i = 0; i < count; i++) {            
            tokenIdList[i] = Fish(nft).mint(msg.sender, geneList[i]);
        }

        remain = remain.sub(count);
        buyCount[msg.sender] += count;

        emit Buy(msg.sender, tokenIdList, geneList);
    }

    function updatePrice(uint256 price_) external onlyAdmin {
        price = price_;
    }

    function updateTime(uint256 startTime_, uint256 endTime_)
        external
        onlyAdmin
    {
        startTime = startTime_;
        endTime = endTime_;
    }

    function updateFishGeneBank(address fishGeneBank_) external onlyAdmin {
        fishGeneBank = IFishGeneBank(fishGeneBank_);
    }
}
