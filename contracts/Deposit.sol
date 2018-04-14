pragma solidity ^0.4.19;

contract AssetManager{
    /*
    * Standard interface contract for deploying SimpleDeposit contracts
    */
    
    address public creator;
    address[] public deposits;
    uint public minimum_deposit_threshold = 0.2 ether;
    uint public minimum_fee = 0.1 ether;
    
    function AssetManager() public{
        creator = msg.sender;
    }
    
    function createDeposit(address assetOwner, uint fee, uint daysUntilExpiry) payable public{
        require(msg.value >= minimum_deposit_threshold && msg.value > fee * 2 ether);
        require(fee * 1 ether > minimum_fee);
        require(daysUntilExpiry >= 1);
        address newDeposit = (new SimpleDeposit).value(msg.value)(msg.sender, assetOwner, fee, daysUntilExpiry);
        deposits.push(newDeposit);
    }
    
    // get a count on how many SimpleDeposit Contracts have been deployed using this
    function getDepositCount() public view returns(uint){
        return deposits.length;
    }
}

contract SimpleDeposit{
    
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
    
    function SimpleDeposit(address _depositor, address _assetOwner, uint _fee, uint _validFor) public payable{
        require(msg.value > 2*_fee);
        depositor = _depositor;
        assetOwner = _assetOwner;
        fee = _fee;
        timeOfCreation = now; 
        validFor = _validFor;
    }
    
    function shareAssetInfo(bytes32 _uniqueAssetIdentifier) onlyAssetOwner public{
        require(now < (timeOfCreation + validFor * 1 days));
        assetInfo = _uniqueAssetIdentifier;
    }
    
    // depositor calls this function after assetInfo has been shared and expiry time is past
    function retrieveDeposit() onlyDepositor public payable{
        require(now > timeOfCreation + validFor * 1 days);
        require(assetInfo != bytes32(0));
        assetOwner.transfer(fee * 1 ether);
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