//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./IFishGeneBank.sol";
import "./IBlindBox.sol";
import "./IWhitelist.sol";
import "../tokens/Fish.sol";
import "../owner/AdminRole.sol";

contract BlindBox2 is IBlindBox2, AdminRole {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using Address for address;

    string public override name;
    address public override nft;
    uint256 public override total;
    uint256 public override sold;
    uint256 public override limit;
    uint256 public override startTime;
    uint256 public override endTime;
    mapping(address => uint8) public override buyCount;
    address public override whitelist;
    bool public override whitelistClosed = true;
    address public override discountWhitelist;
    uint256 public override discount = 100; // 100%
    IFishGeneBank public fishGeneBank;
    address payable private treasury;

    uint256 private _price = 1 * 10**16;

    constructor(
        string memory name_,
        address nft_,
        uint256 total_,
        uint256 limit_,
        uint256 startTime_,
        uint256 endTime_,
        address fishGeneBank_
    ) {
        name = name_;
        nft = nft_;
        total = total_;
        limit = limit_;
        startTime = startTime_;
        endTime = endTime_;
        fishGeneBank = IFishGeneBank(fishGeneBank_);
        treasury = payable(msg.sender);
    }

    function price() public view override returns (uint256) {
        if (
            discount != 100 &&
            IWhitelist(discountWhitelist).contains(msg.sender)
        ) {
            return (_price * discount) / 100;
        } else {
            return _price;
        }
    }

    function remain() public view override returns (uint256) {
        return total - sold;
    }

    function info()
        external
        view
        override
        returns (
            string memory name_,
            address nft_,
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
        price_ = price();
        total_ = total;
        remain_ = remain();
        limit_ = limit;
        startTime_ = startTime;
        endTime_ = endTime;
    }

    function checkWhitelist() public view returns (bool) {
        if (whitelistClosed) {
            return true;
        } else {
            return IWhitelist(whitelist).contains(msg.sender);
        }
    }

    function buyEth(uint8 count) external payable override {
        require(
            block.timestamp >= startTime && block.timestamp < endTime,
            "Non business hours"
        );
        require(remain() >= count, "It's sold out");
        require(
            count > 0 && count <= limit - buyCount[msg.sender],
            "It's sold out"
        );
        require(checkWhitelist(), "You are not on the white list");

        uint256 amount = price() * count;
        require(msg.value == amount, "Insufficient Balance");
        treasury.transfer(amount);

        uint256[] memory tokenIdList = new uint256[](count);
        
        uint256[] memory geneList = fishGeneBank.getGenes(count);

        for (uint256 i = 0; i < count; i++) {
            tokenIdList[i] = Fish(nft).mint(
                msg.sender,
                geneList[i]
            );
        }

        sold += count;
        buyCount[msg.sender] += count;

        emit Buy(msg.sender, tokenIdList, geneList);
    }

    function setNFT(address nft_) external onlyAdmin {
        nft = nft_;
    }

    function setTotal(uint256 total_) external onlyAdmin {
        total = total_;
    }

    function setLimit(uint256 limit_) external onlyAdmin {
        limit = limit_;
    }

    function setTime(uint256 startTime_, uint256 endTime_) external onlyAdmin {
        startTime = startTime_;
        endTime = endTime_;
    }

    function setFishGeneBank(address fishGeneBank_) external onlyAdmin {
        fishGeneBank = IFishGeneBank(fishGeneBank_);
    }

    function setPrice(uint256 price_) external onlyAdmin {
        _price = price_;
    }

    function setWhitelist(address whitelist_, bool whitelistClosed_)
        external
        onlyAdmin
    {
        whitelist = whitelist_;
        whitelistClosed = whitelistClosed_;
    }

    function setDiscount(address whitelist_, uint256 discount_)
        external
        onlyAdmin
    {
        discountWhitelist = whitelist_;
        discount = discount_;
    }

    function setTreasury(address treasury_) external onlyAdmin {
        treasury = payable(treasury_);
    }
}
