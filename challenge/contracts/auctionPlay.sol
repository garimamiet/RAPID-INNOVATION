// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import "../interfaces/IERC20.sol";

contract auctionPlay {
    uint256 public startTime;
    uint256 public endTime;
    uint256 public maxBid;
    uint256 public amount;
    address public maxBidder;
    address public winner;
    address public owner;
    address public asset;
    address public repository;
    bool public isResolved;
    bool private unlocked = true;

    mapping(address => uint256) public playerBid;

    constructor(
        address _owner,
        uint256 _startTime,
        uint256 _endTime,
        uint256 _amount,
        address _asset,
        address _repository
    ) {
        owner = _owner;
        startTime = _startTime;
        endTime = _endTime;
        asset = _asset;
        amount = _amount;
        repository = _repository;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "limited to owner only.");
        _;
    }

    modifier timeIsRight() {
        require(startTime < block.timestamp, "auction not yet started.");
        require(endTime > block.timestamp, "auction ended.");
        _;
    }

    modifier timeOver() {
        require(block.timestamp > endTime, "auction is still running.");
        _;
    }

    modifier lock() {
        require(unlocked == true, "LOCKED");
        unlocked = false;
        _;
        unlocked = true;
    }

    function placeBid() public payable timeIsRight returns (bool) {
        require(playerBid[msg.sender] == 0, "Bid already placed");
        playerBid[msg.sender] = msg.value;
        if (msg.value > maxBid) {
            maxBid = msg.value;
            maxBidder = msg.sender;
        }
        return true;
    }

    function resolve() public onlyOwner timeOver {
        winner = maxBidder;
        uint256 amountToTransfer = IERC20(asset).balanceOf(address(this));
        if (winner != address(0)) {
            winner = maxBidder;
            isResolved = true;

            IERC20(asset).transfer(winner, amountToTransfer);
        } else {
            IERC20(asset).transfer(owner, amountToTransfer);
        }
    }

    function claimAssetPrice() public onlyOwner lock {
        require(isResolved == true, "auction not resolved");
        uint256 ethToSend = playerBid[winner];
        playerBid[winner] = 0;
        payable(msg.sender).transfer(ethToSend);
    }

    function withdraw() public timeOver lock {
        require(msg.sender != winner, "winner can't withdraw.");
        require(playerBid[msg.sender] > 0, "already withdrawn");
        uint256 amountTosend = playerBid[msg.sender];
        playerBid[msg.sender] = 0;
        payable(msg.sender).transfer(amountTosend);
    }

    function getWinner() public view returns (address) {
        return winner;
    }
}
