
## Workflow - how to create a SimpledEposit using a running DepositManager Contract

Note - all fee values should be in Wei( 1 ether = 1,000,000,000,000,000,000 Wei) (convertor- https://etherconverter.online/ or web3.utils.toWei())

* call the createDeposit function - `createDeposit(0xca35b7d915458ef540ade6068dfe2f44e8fa733c, 200000000000000000, 10)`   with the transaction value set to greator than or equal to the fee value ( in this example - value >= 0.4 ether)
* get the address for Simple Deposit Contract by findMyDeposit function and share it with the assetOwner
* assetOwner adds the uniqueAssetIdentifier by calling the `shareAssetInfo()` function
* After the set expiry time, depositor calls the `retrieveDeposit()` function. This will pay the assetOwner his owed fees, then transafer rest of the deposit amount back to the depositor and then self destruct the SimpleDeposit Contract.


- Suppose the AssetOwner never updates the assetInfo on time, the depositor can then call `voidDeposit()` function to get back his deposit and self-destruct the Contract.
- `voidDeposit()` may be called by the depositor for any other reason but only until the assetOwner has *not* shared the assetInfo.


# Description

## contract AssetManager 
interface contract for deploying SimpleDeposit contracts. This contract is only deployed once. This is responsible for creating all SimpleDeposit contracts.

### createDeposit(address assetOwner, uint fee, uint daysUntilExpiry)
This function is called by a depositor to initiate the entire asset/deposit exchange process. This function requires the depositor to be aware of depositor's address, a mutually agreed fee value plus an expiration date.Tis function is always called with a transaction value that is equal to the total deposit.

#### * Note * 

- values of `minimum_deposit_threshold` and `minimum_fee` can be modified. These value ensure that all SimpleDeposit contracts are created with sufficient funds. 
- `msg.value > fee * 2 ether`- this piece of code means that the total deposited value(including fee) is atleast twice the amount of set fees. * This is a good measure to makes sure that that the depositor has atleast the amount equalto the assetOwner's fees locked up within the contract. This can also be changed. *

### getDepositCount()
This is a simply helper function which returns the total number of SimpleDeposit Contracts ever deployed using this AssetManager.

## contract SimpleDeposit

### shareAssetInfo(bytes32 _uniqueAssetIdentifier)
This function is used by the assetowner to share the asset info/ asset identifier. This can only be called from the assetOwner's address.

### retrieveDeposit()
This fucntion is called by depositor to retrieve their deposit by paying the assetOwner his/her fee first. Can only called by depositor's address and after the expiration of the contract. This contract transfers the said amounts and then selfdestructs the contract.

### voidDeposit()
This function is called by the only by the depositor when he/she wants to stop the deposit. This can be in the case when the assetOwner never shares their assetInfo or for any other reason. *Note* - This cannot be called after the assetOwner has shared their assetInfo.

### getDepositAmount()
simply returns the deposited amount within the contract







