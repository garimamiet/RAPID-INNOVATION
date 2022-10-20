# Deployment

* Place your private key in the .env file
* Place your blockchain explorer access token in .env to publish and verify the contract.
* Install dependencies using:
    ```console
    pip -r requirements.txt

* Deploy the repository contract using 
    ```console
    brownie run scripts/deploy.py

# Auction repository contract

### Create New Auction Contract

```Javascript
    function createAuction(asset, startTime, endTime, amount)
```
* Before calling this function, user needs to approve the repository contract to spend the ERC-20 asset.
* Asset is the address of ERC-20 token which is to be auctioned.
* startTime is the epoch time in milliseconds when the auction will start.
*  endTime is the epoch time in milliseconds when the auction will end.
* amount is the number of ERC-20 tokens which are being auctioned.
This function will do the following:
    1. Create a new auction contract
    2. Make the caller of this function, owner of auction contract.
    3. Transfer the ERC-20 tokens as mentioned in amount from user's account to auction contract.
* Now the bidders can bid for this asset.


# Auction contract

### Bidding for the asset
```Javascript
    function placeBid()
```
* This is a payable function and bidder needs to send the Ethers along with the transaction.
* This function records the bidding value equal to the Ethers sent against the address of bidder.
* A bidder can bid only once.
* Bidding can only be done upto the endTime mentioned in the contract.


### Auction Result
```javascript
    function resolve()
```
* This function can only be called by the owner of the auction.
* This function will do the following:
    1. If there are no bids and the auction is not resolved, the assets are transferred back to the auction-owner.
    2. If auction is resolved, the winner is declared.
    3. If auction is resolved successfully and winner is declared, the assets will be transferred to the winner.

### Owner gets the asset price
```Javascript
    function claimAssetPrice()
```
* This function can only be called by the owner after the auction is resolved. It will transfer the bid amount of winner to auction-owner's account.

### Unsuccessful bidders get their money back
```Javascript
    function withdraw()
```
* Any bidder who is not a winner can call this function once after the auction is over (resolved or unresolved). It will return their Ethereum back.

# Testing

* Tests can be run using command:
```console
    brownie test tests/test_1.py
```


