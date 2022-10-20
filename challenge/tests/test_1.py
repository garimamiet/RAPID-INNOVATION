from brownie import accounts, chain, auctionPlay, auctionRepository, Token, interface
import brownie
import pytest
import time

amount = 100
duration = 1 * 60 * 60 * 1000


# --------------Basic Setup-------------------------------

# Repository contract is deployed from accounts[0] and hence accounts[0] is the owner
# of Repository contract.
# Auction contract is deployed from accounts[1] and hence accounts[1] is the owner
# of Auction contract.
# Token contract is sample ERC-20 used as asset and deployed from accounts[1] with totalSupply
# of 1000.
#

# deploying the Repository contract.
@pytest.fixture(scope="module", autouse=True)
def repository():
    repository = auctionRepository.deploy({"from": accounts[0]})
    yield repository


# deloying the ERC-20 asset
@pytest.fixture(scope="module", autouse=True)
def token():
    token = Token.deploy({"from": accounts[1]})
    yield token


# deloying the Auction contract
@pytest.fixture()
def auction_address(repository, token):
    startTime = time.time()

    endTime = startTime + duration

    tx = token.approve(repository, amount, {"from": accounts[1]})
    tx.wait(1)
    tx = repository.createAuction(
        token, startTime, endTime, amount, {"from": accounts[1]}
    )
    tx.wait(1)
    auction_address = repository.getAllAuctions()[-1][0]
    yield auction_address


# isolating all the teat unit functions
@pytest.fixture(autouse=True)
def isolation(fn_isolation):
    pass


# -----------------------------------------------------------------------------------


def test_deploy_auction(token, auction_address):
    contract_balance = token.balanceOf(auction_address)
    # During deployment, asset is passed to the auction contract.
    assert contract_balance == amount


def test_bid(auction_address):
    auction = interface.IauctionPlay(auction_address)
    tx = auction.placeBid({"value": 1 * 10**18, "from": accounts[2]})
    tx.wait(1)
    # Bid value arrived in the contract.
    assert auction.balance() == 1 * 10**18


def test_multiple_bids(auction_address):
    auction = interface.IauctionPlay(auction_address)
    tx = auction.placeBid({"value": 1 * 10**18, "from": accounts[3]})
    tx.wait(1)
    with brownie.reverts("Bid already placed"):
        tx = auction.placeBid({"value": 2 * 10**18, "from": accounts[3]})
        tx.wait(1)


def test_multiple_user_bids(auction_address):
    auction = interface.IauctionPlay(auction_address)
    bids = [1, 2, 5, 0.5, 4]
    bidders = [accounts[2], accounts[3], accounts[4], accounts[5], accounts[6]]
    for i in range(0, 5):
        tx = auction.placeBid({"value": bids[i] * 10**18, "from": bidders[i]})
        tx.wait(1)
    # Bids are accumulating in the contract.
    assert auction.balance() == 12.5 * 10**18


def test_bid_after_time(auction_address):
    auction = interface.IauctionPlay(auction_address)
    chain.sleep(duration)
    # can't bid after the auction is over.
    with brownie.reverts("auction ended."):
        tx = auction.placeBid({"value": 2 * 10**18, "from": accounts[2]})
        tx.wait(1)


def test_resolve_before_time(auction_address):
    auction = interface.IauctionPlay(auction_address)
    # can't resolve, if the auction is going on.
    with brownie.reverts("auction is still running."):
        tx = auction.resolve({"from": accounts[1]})
        tx.wait(1)


def test_resolve_called_by_wrong_address(auction_address):
    auction = interface.IauctionPlay(auction_address)
    chain.sleep(duration)
    # only auctio owner, accounts[1], can resolve the auction.
    with brownie.reverts("limited to owner only."):
        tx = auction.resolve({"from": accounts[2]})
        tx.wait(1)


def test_resolve_without_bid(auction_address, token):
    auction = interface.IauctionPlay(auction_address)
    assert token.balanceOf(auction_address) == 100
    chain.sleep(duration)
    tx = auction.resolve({"from": accounts[1]})
    tx.wait(1)
    # asset transferred back to the auction owner, accounts[1]
    assert token.balanceOf(auction_address) == 0
    assert token.balanceOf(accounts[1]) == 1000
    # winner address not set.
    assert auction.getWinner() == "0x0000000000000000000000000000000000000000"


def test_resolve_after_bidding(auction_address, token):
    auction = interface.IauctionPlay(auction_address)
    bids = [1, 2, 5, 0.5, 4]
    bidders = [accounts[2], accounts[3], accounts[4], accounts[5], accounts[6]]
    for i in range(0, 5):
        tx = auction.placeBid({"value": bids[i] * 10**18, "from": bidders[i]})
        tx.wait(1)
    chain.sleep(duration)
    tx = auction.resolve({"from": accounts[1]})
    tx.wait(1)
    # winner address set.
    assert auction.getWinner() == accounts[4]
    # asset transferred to the winner
    assert token.balanceOf(accounts[4]) == amount
    # asset price transferred to auction owner
    balance_before_resolve = accounts[0].balance()
    tx = auction.claimAssetPrice({"from": accounts[1]})
    tx.wait(1)
    assert accounts[1].balance() == balance_before_resolve + (5 * 10**18)
