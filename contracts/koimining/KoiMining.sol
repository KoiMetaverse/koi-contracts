// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./IKoiMining.sol";
import "../owner/Controller.sol";
import "../tokens/Fish.sol";
import "../tokens/FishStatus.sol";
import "../tokens/IFishGene.sol";

// import "hardhat/console.sol";

contract KoiMining is IKoiMining, Controller, IERC721Receiver {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using Address for address;
    using EnumerableSet for EnumerableSet.AddressSet;
    using EnumerableSet for EnumerableSet.UintSet;

    struct FishData {
        uint16 epochPoint; //*100
        uint16 begin;
        uint16 end;
    }

    struct EpochGroupData {
        uint32 totalFish;
        uint32 totalFishPoint;
    }

    struct UserGroupData {
        EnumerableSet.UintSet fishSet;
        uint16 lastUpdateReward;
        uint256 reward;
    }

    uint8[] private _groupIds = [1, 2, 3, 4, 5];
    uint256[] private _dailyOutput = [
        6666 * 10**18,
        6666 * 10**18,
        6666 * 10**18,
        6666 * 10**18,
        6666 * 10**18
    ];

    uint256 public interval = 1 days;

    mapping(uint256 => mapping(uint8 => EpochGroupData)) public epochMap; //epoch groupId EpochGroupData

    mapping(uint256 => FishData) public fishMap; //tokenId FishData

    mapping(address => mapping(uint8 => UserGroupData)) private userMap; //account groupId UserGroupData

    EnumerableSet.AddressSet private _userSet;

    Fish public fish;
    IFishGene public fishGene;
    FishStatus public fishStatus;
    address public override coin;

    constructor(
        uint32 startTime_,
        uint32 endTime_,
        address nft_,
        address fishGene_,
        address fishStatus_,
        address coin_
    ) Controller("KoiMining", startTime_, endTime_) {
        fish = Fish(nft_);
        fishGene = IFishGene(fishGene_);
        fishStatus = FishStatus(fishStatus_);
        coin = coin_;
    }

    function nft() external view override returns (address) {
        return address(fish);
    }

    function groupIds() external view override returns (uint8[] memory) {
        return _groupIds;
    }

    function dailyOutput() external view override returns (uint256[] memory) {
        return _dailyOutput;
    }

    function dailyOutput(uint8 groupId) internal view returns (uint256) {
        for (uint256 i = 0; i < _groupIds.length; i++) {
            if (groupId == _groupIds[i]) {
                return _dailyOutput[i];
            }
        }
        return 0;
    }

    function totalNft() external view override returns (uint256[] memory) {
        uint256 epoch_ = currentEpoch();
        uint256[] memory cntLs = new uint256[](_groupIds.length);
        for (uint256 i = 0; i < _groupIds.length; i++) {
            cntLs[i] = epochMap[epoch_][_groupIds[i]].totalFish;
        }
        return cntLs;
    }

    function totalNftPoint() external view override returns (uint256[] memory) {
        uint256 epoch_ = currentEpoch();
        uint256[] memory pointLs = new uint256[](_groupIds.length);
        for (uint256 i = 0; i < _groupIds.length; i++) {
            pointLs[i] = epochMap[epoch_][_groupIds[i]].totalFish;
        }
        return pointLs;
    }

    function currentEpoch() public virtual view returns (uint256) {
        if(block.timestamp <= startTime){
            return 0;
        }
        return (block.timestamp - startTime) / interval;
    }

    function _fishGroupId(uint256 tokenId) internal view returns (uint8) {
        uint256 groupId;
        (, groupId) = fishGene.getSuitGroup(fish.gene(tokenId));
        return uint8(groupId);
    }

    function _point(
        uint256 epoch,
        uint256 end,
        uint256 epochPoint
    ) internal pure returns (uint256) {
        return (epochPoint * (end - epoch)).div(100);
    }

    function _miningCount(uint256 epoch, uint256 end)
        internal
        pure
        returns (uint256)
    {
        return epoch >= end ? 25 : 25 - (end - epoch);
    }

    function _fishPoint(uint256 tokenId, uint256 epoch)
        internal
        view
        returns (uint256)
    {
        if (epoch >= fishMap[tokenId].end) {
            return 0;
        }
        return _point(epoch, fishMap[tokenId].end, fishMap[tokenId].epochPoint);
    }

    function _userGroupPointList(address user, uint8 groupId)
        internal
        view
        returns (uint256[] memory)
    {
        uint256 begin = userMap[msg.sender][groupId].lastUpdateReward;
        // if (begin == 0) {
        //     return new uint256[](0);
        // }
        uint256 end = currentEpoch();
        require(end > begin, "not user point");

        if (end - begin > 25) {
            end = begin + 25;
        }

        uint256[] memory pointList = new uint256[](end - begin);

        for (uint256 i = 0; i < userMap[user][groupId].fishSet.length(); i++) {
            uint256 tokenId = userMap[user][groupId].fishSet.at(i);

            for (uint256 j = 0; j < pointList.length; j++) {
                pointList[j] += _fishPoint(tokenId, begin + j);
            }
        }
        return pointList;
    }

    function _addFish(uint256 tokenId, uint8 groupId) internal {
        uint256 length = 25;
        uint256 fishMiningCount = fishStatus.koiMiningTimes(tokenId);
        require(fishMiningCount < length, "This fish cannot be mined");

        if (fishMiningCount > 0) {
            length -= fishMiningCount;
        }

        uint32 originalPoint = uint32(fishStatus.point(tokenId));
        // console.log("point: ", originalPoint);
        uint256 epochPoint = originalPoint * 4;

        uint256 begin = currentEpoch();
        uint256 end = begin + length;
        fishMap[tokenId].epochPoint = uint16(epochPoint);
        fishMap[tokenId].begin = uint16(begin);
        fishMap[tokenId].end = uint16(end);

        for (uint256 i = begin; i < end; i++) {
            epochMap[i][groupId].totalFishPoint += uint32(
                _point(i, end, epochPoint)
            );
            epochMap[i][groupId].totalFish += 1;
        }
    }

    function _removeFish(uint256 tokenId, uint8 groupId) internal {
        uint256 epochPoint = fishMap[tokenId].epochPoint;
        uint256 epoch = currentEpoch();
        uint256 end = fishMap[tokenId].end;

        fishStatus.setKoiMiningTimes(tokenId, _miningCount(epoch, end));

        for (uint256 i = epoch; i < end; i++) {
            epochMap[i][groupId].totalFishPoint -= uint32(
                _point(i, end, epochPoint)
            );
            epochMap[i][groupId].totalFish -= 1;
        }

        delete fishMap[tokenId];
    }

    function myNft()
        external
        view
        override
        returns (IFishStatus.FishInfo[] memory, uint8[] memory)
    {
        IFishStatus.FishInfo[] memory fishInfoList;
        uint8[] memory fishGroupList;

        uint256 length;
        for (uint256 i = 0; i < _groupIds.length; i++) {
            length += userMap[msg.sender][_groupIds[i]].fishSet.length();
        }

        if (length > 0) {
            uint256[] memory tokenIds = new uint256[](length);
            fishGroupList = new uint8[](length);
            uint256 idx = 0;

            for (uint256 i = 0; i < _groupIds.length; i++) {
                uint8 gid = _groupIds[i];
                uint256 len = userMap[msg.sender][gid].fishSet.length();
                for (uint256 j = 0; j < len; j++) {
                    // console.log(idx, gid, j);
                    tokenIds[idx] = userMap[msg.sender][gid].fishSet.at(j);
                    fishGroupList[idx] = gid;
                    idx++;
                }
            }

            fishInfoList = fishStatus.fishList(tokenIds);

            for (uint256 i = 0; i < length; i++) {
                fishInfoList[i] = getNft(tokenIds[i]);
            }
        }

        return (fishInfoList, fishGroupList);
    }

    function getNft(uint256 tokenId)
        public
        view
        returns (IFishStatus.FishInfo memory)
    {
        IFishStatus.FishInfo memory fishInfo = fishStatus.fishInfo(tokenId);
        fishInfo.koiMiningTimes = uint16(
            _miningCount(currentEpoch(), fishMap[tokenId].end)
        );
        return fishInfo;
    }

    function _earnedGroup(uint8 groupId)
        internal
        view
        returns (uint256 reward)
    {
        uint256[] memory pointLs;
        uint256 begin = userMap[msg.sender][groupId].lastUpdateReward;
        if (begin == currentEpoch()) {
            return 0;
        }

        pointLs = _userGroupPointList(msg.sender, groupId);

        for (uint256 i = 0; i < pointLs.length; i++) {
            uint256 totalFishPoint = epochMap[begin + i][groupId]
                .totalFishPoint;

            if (totalFishPoint == 0 || pointLs[i] == 0) {
                continue;
            }

            reward += (_dailyOutput[groupId] * pointLs[i]).div(totalFishPoint);
        }

        // console.log("_earnedGroup", reward);
    }

    function _earned() internal view returns (uint256 reward) {
        for (uint256 i = 0; i < _groupIds.length; i++) {
            reward += _earnedGroup(_groupIds[i]);
        }
    }

    function _updateRewardGroup(uint8 groupId) internal {
        if (userMap[msg.sender][groupId].lastUpdateReward == currentEpoch()) {
            return;
        }

        uint256 aumount = _earnedGroup(groupId);
        if (aumount > 0) {
            userMap[msg.sender][groupId].reward += aumount;
            userMap[msg.sender][groupId].lastUpdateReward = uint16(
                currentEpoch()
            );
        }
    }

    function _updateReward() internal {
        for (uint256 i = 0; i < _groupIds.length; i++) {
            _updateRewardGroup(_groupIds[i]);
        }
    }

    function earned() public view override returns (uint256) {
        if (!_userSet.contains(msg.sender)) {
            return 0;
        }

        uint256 reward = _earned();

        for (uint256 i = 0; i < _groupIds.length; i++) {
            reward += userMap[msg.sender][_groupIds[i]].reward;
        }
        return reward;
    }

    function stakeNft(uint256 tokenId, uint8 groupId) external override {
        _updateReward();

        bool usable = false;
        for (uint256 i = 0; i < _groupIds.length; i++) {
            if (_groupIds[i] == groupId) {
                usable = true;
                break;
            }
        }
        if (!usable) {
            return;
        }
        // console.log(groupId, _fishGroupId(tokenId));

        if (groupId != _fishGroupId(tokenId)) {
            return;
        }

        _userSet.add(msg.sender);

        fish.safeTransferFrom(msg.sender, address(this), tokenId);

        userMap[msg.sender][groupId].fishSet.add(tokenId);

        _addFish(tokenId, groupId);

        userMap[msg.sender][groupId].lastUpdateReward = uint16(currentEpoch());

        emit Stake(msg.sender, tokenId, groupId);
    }

    function withdrawNft(uint256 tokenId) public override {
        _updateReward();

        uint8 groupId = _fishGroupId(tokenId);

        if (!userMap[msg.sender][groupId].fishSet.contains(tokenId)) {
            return;
        }

        _removeFish(tokenId, _fishGroupId(tokenId));
        userMap[msg.sender][groupId].fishSet.remove(tokenId);

        fish.safeTransferFrom(address(this), msg.sender, tokenId);

        emit Withdraw(msg.sender, tokenId, groupId);
    }

    function withdrawNftAll() public override {
        for (uint256 i = 0; i < _groupIds.length; i++) {
            for (
                uint256 j = 0;
                j < userMap[msg.sender][_groupIds[i]].fishSet.length();
                j++
            ) {
                uint256 tokenId = userMap[msg.sender][_groupIds[i]].fishSet.at(
                    j
                );
                withdrawNft(tokenId);
            }
        }
    }

    function getReward() public override {
        _updateReward();

        uint256 amount = earned();
        if (amount == 0) {
            return;
        }

        IERC20(coin).safeTransfer(msg.sender, amount);

        for (uint256 i = 0; i < _groupIds.length; i++) {
            userMap[msg.sender][_groupIds[i]].reward = 0;
        }

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

    function setFish(address fish_) external onlyAdmin {
        fish = Fish(fish_);
    }

    function setFishStatus(address fishStatus_) external onlyAdmin {
        fishStatus = FishStatus(fishStatus_);
    }

    function setFishGene(address fishGene_) external onlyAdmin {
        fishGene = IFishGene(fishGene_);
    }

    function setCoin(address coin_) external onlyAdmin {
        coin = coin_;
    }

    function setGroupIds(uint8[] memory groupIds_) external onlyAdmin {
        _groupIds = groupIds_;
    }

    function setDailyOutput(uint256[] memory dailyOutput_) external onlyAdmin {
        for (uint256 i = 0; i < dailyOutput_.length; i++) {
            _dailyOutput[i] = dailyOutput_[i];
        }
    }
}
