//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

interface IBlindBox {
    function name() external view returns (string memory);

    function nft() external view returns (address);

    function coin() external view returns (address);

    function price() external view returns (uint256);

    function total() external view returns (uint256);

    function remain() external view returns (uint256);

    function limit() external view returns (uint256);

    function startTime() external view returns (uint256);

    function endTime() external view returns (uint256);

    function info()
        external
        view
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
        );

    function buyCount(address) external view returns (uint8);

    function buy(uint8 count) external;

    function buyEth(uint8 count) external payable;

    event Buy(address user, uint256[] tokenIdList, uint256[] geneList);
}

interface IBlindBox2 {
    function name() external view returns (string memory);

    function nft() external view returns (address);

    function price() external view returns (uint256);

    function total() external view returns (uint256);

    function sold() external view returns (uint256);

    function remain() external view returns (uint256);

    function limit() external view returns (uint256);

    function startTime() external view returns (uint256);

    function endTime() external view returns (uint256);

    function info()
        external
        view
        returns (
            string memory name_,
            address nft_,
            uint256 price_,
            uint256 total_,
            uint256 remain_,
            uint256 limit_,
            uint256 startTime_,
            uint256 endTime_
        );

    function buyCount(address) external view returns (uint8);

    function whitelistClosed() external view returns (bool);

    function whitelist() external view returns (address);

    function discountWhitelist() external view returns (address);

    function discount() external view returns (uint256);

    function buyEth(uint8 count) external payable;

    event Buy(address user, uint256[] tokenIdList, uint256[] geneList);
}

interface IBlindBox3 {
    function nft() external view returns (address);

    function price() external view returns (uint256);

    function total() external view returns (uint256);

    function sold() external view returns (uint256);

    function remain() external view returns (uint256);

    function limit() external view returns (uint256);

    function info()
        external
        view
        returns (
            string memory name_,
            address nft_,
            uint256 price_,
            uint256 total_,
            uint256 remain_,
            uint256 limit_,
            uint256 startTime_,
            uint256 endTime_
        );

    function buyCount(address account) external view returns (uint8);

    function freeDrawCount(address account) external view returns (uint32);

    function freeTimes(address account) external view returns (uint256);

    function whitelistClosed() external view returns (bool);

    function whitelist() external view returns (address);

    function discountWhitelist() external view returns (address);

    function discount() external view returns (uint256);

    function buyEth(uint8 count) external payable;

    function freeDraw(uint8 count) external;

    event Buy(address user, uint256[] tokenIdList, uint256[] geneList);

    event FreeDraw(address user, uint256[] tokenIdList, uint256[] geneList);
}

