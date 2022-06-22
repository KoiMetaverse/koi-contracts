// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./IBreeding.sol";
import "../owner/Controller.sol";
import "../tokens/Token.sol";
import "../tokens/Fish.sol";
import "../tokens/FishStatus.sol";
import "../tokens/FishGene.sol";
import "../shellmining/IShellMining.sol";

contract Breeding is IBreeding, Controller {
    using SafeMath for uint256;
    using Address for address;

    Fish public fish;
    FishStatus public fishStatus;
    FishGene public fishGene;
    address public override coin;
    IShellMining public pool;

    uint256 public K = 500 * 10**18;

    constructor(
        uint32 startTime_,
        uint32 endTime_,
        address nft_,
        address fishStatus_,
        address fishGene_,
        address coin_,
        address pool_
    ) Controller("Breeding", startTime_, endTime_) {
        fish = Fish(nft_);
        fishStatus = FishStatus(fishStatus_);
        fishGene = FishGene(fishGene_);
        coin = coin_;
        pool = IShellMining(pool_);
    }

    function nft() external view override returns (address) {
        return address(fish);
    }

    function getFee(uint256 fatherId, uint256 motherId)
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

    function breeding(uint256 fatherId, uint256 motherId) external override checkTime {
        require(
            fish.ownerOf(fatherId) == msg.sender &&
                fish.ownerOf(motherId) == msg.sender,
            "You are not the owner of fish"
        );

        uint256 fee = getFee(fatherId, motherId);
        SHELL(coin).burnFrom(msg.sender, fee);

        uint256 gene0 = fish.gene(fatherId);
        uint256 gene1 = fish.gene(motherId);
        uint256 gene = fishGene.newGene(gene0, gene1);

        uint256 childId = fish.mint(msg.sender, gene);

        fishStatus.breedingTimesAdd(fatherId);
        fishStatus.breedingTimesAdd(motherId);

        emit Breeding(msg.sender, fatherId, motherId, childId, gene, fee);
    }

    function setFish(address fish_) external onlyAdmin {
        fish = Fish(fish_);
    }

    function setFishStatus(address fishStatus_) external onlyAdmin {
        fishStatus = FishStatus(fishStatus_);
    }

    function setCoin(address coin_) external onlyAdmin {
        coin = coin_;
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
}
