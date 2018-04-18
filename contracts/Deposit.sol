pragma solidity ^0.4.22;

/**
 * The DepositManager contract initates and deploys SimpleDeposit Contracts
 */
contract DepositManager {

    address public creator;
    address[] public deposits;
    uint public minimum_deposit_threshold = 0.2 ether;
    uint public minimum_fee = 0.1 ether;
    mapping (address => address) depositorToDeposit;

    constructor () public{
        creator = msg.sender;
    }

    function createDeposit(address assetOwner, uint feeInWei, uint hoursUntilExpiry) payable public {   
        require (msg.value >= minimum_deposit_threshold && msg.value >= 2 * feeInWei);
        require(feeInWei >= minimum_fee);
        require (hoursUntilExpiry >= 1);
        address newDeposit = (new SimpleDeposit).value(msg.value)(msg.sender, assetOwner, feeInWei, hoursUntilExpiry);
        deposits.push(newDeposit);
        depositorToDeposit[msg.sender] = newDeposit;
    }

    // get a count on how many SimpleDeposit Contracts have been deployed using this
    function getCount() public view returns(uint) {
        return deposits.length;
    }

    //returns the address of last SimpleDeposit Contract created by the sender
    function findMyDeposit () public view returns(address) {
        assert(depositorToDeposit[msg.sender] != address(0x0));
        return depositorToDeposit[msg.sender];
    }
}

/**
 * The SimpleDeposit contract manages individual Deposits
 */
contract SimpleDeposit {

    address public depositor;
    address public assetOwner;
    bytes32 private assetInfo;
    uint public fee;
    uint public timeOfCreation;
    uint public validFor;

    modifier onlyDepositor(){
        require(msg.sender == depositor);
        _;
    }
    
    modifier onlyAssetOwner(){
        require(msg.sender == assetOwner);
        _;
    }

    constructor(address _depositor, address _assetOwner, uint _feeInWei, uint _validFor) public payable{
        require(msg.value >= 2*_feeInWei);
        depositor = _depositor;
        assetOwner = _assetOwner;
        fee = _feeInWei;
        timeOfCreation = now; 
        validFor = _validFor;
    }

    function shareAssetInfo(bytes32 _uniqueAssetIdentifier) onlyAssetOwner public{
        require(now < (timeOfCreation + validFor * 1 hours));
        assetInfo = _uniqueAssetIdentifier;
    }
    
    // depositor calls this function after assetInfo has been shared and expiry time is past
    function retrieveDeposit() onlyDepositor public payable{
        require(now > timeOfCreation + validFor * 1 hours);
        require(assetInfo != bytes32(0));
        assetOwner.transfer(fee);
        selfdestruct(depositor);
    }
    
    // Void Deposit
    // a depositor can only void a deposit if the assetOwner has Not already shared assetInfo 
    function voidDeposit() onlyDepositor public payable{
        require(assetInfo == bytes32(0));
        selfdestruct(depositor);
    }
    
    function getDepositAmount() public view returns(uint){
        address thisDeposit = this;
        return thisDeposit.balance;
    }
}


