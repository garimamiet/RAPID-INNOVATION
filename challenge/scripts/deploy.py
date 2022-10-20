from brownie import config, accounts, auctionRepository
from dotenv import load_dotenv

load_dotenv()
import os


def deploy():
    accounts.add(private_key=config["pvt_key"])
    owner = accounts[-1]
    auctionRepository.deploy({"from": owner}, publish_source=True)


def main():
    deploy()
