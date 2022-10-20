// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import "./auctionPlay.sol";

contract auctionRepository {
    mapping(address => address) public auctionToAsset;

    struct auction {
        address auctionContract;
        address asset;
        uint256 amount;
    }

    auction[] public auctions;

    function createAuction(
        address asset,
        uint256 startTime,
        uint256 endTime,
        uint256 amount
    ) public returns (address) {
        require(
            IERC20(asset).balanceOf(msg.sender) >= amount,
            "not enough asset"
        );
        address deployer = msg.sender;

        auctionPlay myAuction = new auctionPlay(
            msg.sender,
            startTime,
            endTime,
            amount,
            asset,
            address(this)
        );

        IERC20(asset).transferFrom(deployer, address(myAuction), amount);

        auctions.push(auction(address(myAuction), asset, amount));
        auctionToAsset[address(myAuction)] = asset;

        return address(myAuction);
    }

    function getAllAuctions() public view returns (auction[] memory) {
        return auctions;
    }

    function fetchAuction(address _auctionContract)
        public
        view
        returns (auction memory)
    {
        uint256 l = auctions.length;

        for (uint256 i = 0; i < l; i++) {
            if (auctions[i].auctionContract == _auctionContract) {
                return auctions[i];
            }
        }
        return auction(address(0), address(0), 0);
    }
}
