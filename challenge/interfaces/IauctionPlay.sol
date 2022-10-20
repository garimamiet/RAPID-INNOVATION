// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

interface IauctionPlay {
    function placeBid() external payable returns (bool);

    function resolve() external;

    function withdraw() external;

    function getWinner() external view returns (address);

    function claimAssetPrice() external;
}
