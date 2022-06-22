// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./IShellMining.sol";
import "../owner/Controller.sol";
import "../tokens/Fish.sol";
import "../tokens/FishStatus.sol";
import "../tokens/Token.sol";

contract ShellMining1 is IShellMining, Controller, IERC721Receiver {
    using SafeMath for uint256;
    using Address for address;
    using EnumerableSet for EnumerableSet.AddressSet;
    using EnumerableSet for EnumerableSet.UintSet;

    struct FishData {
        uint16 epochPower; //*100
        uint16 begin;
        uint16 end;
    }

    struct EpochData {
        uint32 totalFish;
        uint32 totalFishPower;
        uint32 totalFishOriginalPower;
    }

    struct UserData {
        EnumerableSet.UintSet fishSet;
        uint16 lastUpdateReward;
        uint256 reward;
    }

    uint256 public interval = 1 days;

    mapping(uint256 => EpochData) public epochMap;

    mapping(uint256 => FishData) public fishMap;

    mapping(address => UserData) private userMap;
    EnumerableSet.AddressSet private _userSet;

    Fish public fish;
    FishStatus public fishStatus;
    address public override coin;

    uint256[2][18] public productionTable;

    constructor(
        uint32 startTime_,
        uint32 endTime_,
        address nft_,
        address fishStatus_,
        address coin_
    ) Controller("ShellMining1", startTime_, endTime_) {
        fish = Fish(nft_);
        fishStatus = FishStatus(fishStatus_);
        coin = coin_;
    }

    function nft() external view override returns (address) {
        return address(fish);
    }

    function totalNft() external view override returns (uint256) {
        return epochMap[currentEpoch()].totalFish;
    }

    function totalNftPower() external view override returns (uint256) {
        return epochMap[currentEpoch()].totalFishPower;
    }

    function totalFishOriginalPower() external view override returns (uint256) {
        return epochMap[currentEpoch()].totalFishOriginalPower;
    }

    function currentEpoch() public virtual view returns (uint256) {
        if(block.timestamp <= startTime){
            return 0;
        }
        return (block.timestamp - startTime) / interval;
    }

    // m = K * x ** 0.9 / x
    function production(uint256 fishCnt) public view returns (uint256) {
        if (fishCnt <= productionTable[0][0]) {
            return productionTable[0][1] * fishCnt;
        }

        if (fishCnt >= productionTable[productionTable.length - 1][0]) {
            return productionTable[productionTable.length - 1][1] * fishCnt;
        }

        uint256 n;
        for (uint256 i = 1; i < productionTable.length; i++) {
            if (fishCnt == productionTable[i][0]) {
                return productionTable[i][1] * fishCnt;
            }

            if (fishCnt < productionTable[i][0]) {
                n = i;
                break;
            }
        }

        uint256 n1 = productionTable[n - 1][0];
        uint256 n2 = productionTable[n][0];
        uint256 v1 = productionTable[n - 1][1];
        uint256 v2 = productionTable[n][1];

        return ((n1 * v1 + n2 * v2) / (n1 + n2)) * fishCnt;
    }

    function _power(
        uint256 epoch,
        uint256 end,
        uint256 epochPower
    ) internal pure returns (uint256) {
        return (epochPower * (end - epoch)).div(100);
    }

    function _miningCount(uint256 epoch, uint256 end)
        internal
        pure
        returns (uint256)
    {
        return epoch >= end ? 25 : 25 - (end - epoch);
    }

    function _fishPower(uint256 tokenId, uint256 epoch)
        internal
        view
        returns (uint256)
    {
        if (epoch >= fishMap[tokenId].end) {
            return 0;
        }
        return _power(epoch, fishMap[tokenId].end, fishMap[tokenId].epochPower);
    }

    function _userPowerList(address user)
        internal
        view
        returns (uint256[] memory)
    {
        uint256 begin = userMap[msg.sender].lastUpdateReward;
        uint256 end = currentEpoch();
        require(end > begin, "not user power");

        if (end - begin > 25) {
            end = begin + 25;
        }

        uint256[] memory powerList = new uint256[](end - begin);

        for (uint256 i = 0; i < userMap[user].fishSet.length(); i++) {
            uint256 tokenId = userMap[user].fishSet.at(i);

            for (uint256 j = 0; j < powerList.length; j++) {
                powerList[j] += _fishPower(tokenId, begin + j);
            }
        }
        return powerList;
    }

    function _addFish(uint256 tokenId) internal {
        uint256 length = 25;
        uint256 fishMiningCount = fishStatus.shellMiningTimes(tokenId);
        require(fishMiningCount < length, "This fish cannot be mined");

        if (fishMiningCount > 0) {
            length -= fishMiningCount;
        }

        uint32 originalPower = uint32(fishStatus.power(tokenId));
        uint256 epochPower = originalPower * 4;

        uint256 begin = currentEpoch();
        uint256 end = begin + length;
        fishMap[tokenId].epochPower = uint16(epochPower);
        fishMap[tokenId].begin = uint16(begin);
        fishMap[tokenId].end = uint16(end);

        for (uint256 i = begin; i < end; i++) {
            epochMap[i].totalFishPower += uint32(_power(i, end, epochPower));
            epochMap[i].totalFish += 1;
            epochMap[i].totalFishOriginalPower += originalPower;
        }
    }

    function _removeFish(uint256 tokenId) internal {
        uint256 epochPower = fishMap[tokenId].epochPower;
        uint256 epoch = currentEpoch();
        uint256 end = fishMap[tokenId].end;
        uint32 originalPower = uint32(epochPower / 4);

        fishStatus.setShellMiningTimes(tokenId, _miningCount(epoch, end));

        for (uint256 i = epoch; i < end; i++) {
            epochMap[i].totalFishPower -= uint32(_power(i, end, epochPower));
            epochMap[i].totalFish -= 1;
            epochMap[i].totalFishOriginalPower -= originalPower;
        }

        delete fishMap[tokenId];
    }

    function myNft(uint256 limit, uint256 offset)
        external
        view
        override
        returns (IFishStatus.FishInfo[] memory)
    {
        uint256 length = userMap[msg.sender].fishSet.length();

        require(offset <= length, "offset err");

        length -= offset;
        if (limit < length) {
            length = limit;
        }

        uint256[] memory tokenIds = new uint256[](length);
        for (uint256 i = 0; i < length; i++) {
            tokenIds[i] = userMap[msg.sender].fishSet.at(i + offset);
        }

        IFishStatus.FishInfo[] memory fishInfoList = fishStatus.fishList(
            tokenIds
        );

        for (uint256 i = 0; i < length; i++) {
            fishInfoList[i] = getNft(tokenIds[i]);
        }

        return fishInfoList;
    }

    function getNft(uint256 tokenId)
        public
        view
        override
        returns (IFishStatus.FishInfo memory)
    {
        IFishStatus.FishInfo memory fishInfo = fishStatus.fishInfo(tokenId);
        fishInfo.shellMiningTimes = uint16(
            _miningCount(currentEpoch(), fishMap[tokenId].end)
        );
        return fishInfo;
    }

    function _earned() internal view returns (uint256 reward) {
        if (userMap[msg.sender].lastUpdateReward == currentEpoch()) {
            return 0;
        }
        uint256[] memory userPowerLs;
        uint256 begin = userMap[msg.sender].lastUpdateReward;
        userPowerLs = _userPowerList(msg.sender);

        for (uint256 i = 0; i < userPowerLs.length; i++) {
            uint256 totalFish = epochMap[begin + i].totalFish;
            uint256 totalFishPower = epochMap[begin + i].totalFishPower;

            if (totalFishPower == 0 || userPowerLs[i] == 0) {
                continue;
            }

            reward += (production(totalFish) * userPowerLs[i]).div(
                totalFishPower
            );
        }
    }

    function _updateReward() internal {
        if (userMap[msg.sender].lastUpdateReward == currentEpoch()) {
            return;
        }

        uint256 aumount = _earned();
        if (aumount > 0) {
            userMap[msg.sender].reward += aumount;
            userMap[msg.sender].lastUpdateReward = uint16(currentEpoch());
        }
    }

    function earned() public view override returns (uint256) {
        if (!_userSet.contains(msg.sender)) {
            return 0;
        }
        return userMap[msg.sender].reward + _earned();
    }

    function stakeNft(uint256[] memory tokenIds) external override {
        _updateReward();

        _userSet.add(msg.sender);

        for (uint256 i = 0; i < tokenIds.length; i++) {
            uint256 tokenId = tokenIds[i];

            fish.safeTransferFrom(msg.sender, address(this), tokenId);

            userMap[msg.sender].fishSet.add(tokenId);

            _addFish(tokenId);

            userMap[msg.sender].lastUpdateReward = uint16(currentEpoch());
        }

        emit Stake(msg.sender, tokenIds);
    }

    function withdrawNft(uint256[] memory tokenIds) public override {
        _updateReward();

        for (uint256 i = 0; i < tokenIds.length; i++) {
            uint256 tokenId = tokenIds[i];

            fish.safeTransferFrom(address(this), msg.sender, tokenId);

            _removeFish(tokenId);
            userMap[msg.sender].fishSet.remove(tokenId);
        }

        if (
            userMap[msg.sender].fishSet.length() == 0 &&
            userMap[msg.sender].reward == 0
        ) {
            _userSet.remove(msg.sender);
            delete userMap[msg.sender];
        }

        emit Withdraw(msg.sender, tokenIds);
    }

    function withdrawNftAll() public override {
        uint256[] memory tokenIds = new uint256[](
            userMap[msg.sender].fishSet.length()
        );
        for (uint256 i = 0; i < userMap[msg.sender].fishSet.length(); i++) {
            tokenIds[i] = userMap[msg.sender].fishSet.at(i);
        }
        withdrawNft(tokenIds);
    }

    function getReward() public override {
        _updateReward();

        uint256 amount = userMap[msg.sender].reward;
        if (amount == 0) {
            return;
        }

        SHELL(coin).mint(msg.sender, amount);

        userMap[msg.sender].reward = 0;

        emit Reward(msg.sender, amount);
    }

    function exit() external override {
        getReward();
        withdrawNftAll();
    }

    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }

    function setProductionTable(uint256[2][18] memory productionTable_)
        external
        onlyAdmin
    {
        for (uint256 i = 0; i < productionTable_.length; i++) {
            for (uint256 j = 0; j < productionTable_[i].length; j++) {
                productionTable[i][j] = productionTable_[i][j];
            }
        }
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
}
