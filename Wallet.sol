pragma solidity ^0.5.17;

import "./OwnedBy.sol";

contract Wallet is OwnedBy {
    
    constructor(uint8 maxNumOwners) OwnedBy(maxNumOwners) public {}
    
    struct Transactions {
        int amount;
        uint timestamps;
    }
    
    struct Balance {
        uint totalBalance;
        uint numPayments;
        mapping(uint => Transactions) transactions;
    }
    
    mapping(address => Balance) public wallets;
    uint public walletBalance;
    Transactions[] internal mainTransactions;
    
    modifier isAmountValid(uint _withdrawalAmount) {
        require(wallets[msg.sender].totalBalance >= _withdrawalAmount, "You do not have enough funds");
        _;
    }
    
    function addTransactionToMainAccount(int _amount) internal {
        Transactions memory transaction = Transactions(int(_amount), block.timestamp);
        
        mainTransactions.push(transaction);
    }
    
    function addTransactionToAccount(address _to, int _amount) internal {
        Transactions memory transaction = Transactions(int(_amount), block.timestamp);
        
        wallets[_to].transactions[wallets[_to].numPayments] = transaction;
        wallets[_to].numPayments++;
    }
    
    function addMoneyToWallet() public payable {
        assert(walletBalance + msg.value >= walletBalance);
        walletBalance += msg.value;
        
        addTransactionToMainAccount(int(msg.value));
    }
    
    function withdrawMoney(address payable _to, uint _withdrawalAmount) public isAmountValid(_withdrawalAmount) {
        assert(wallets[msg.sender].totalBalance - _withdrawalAmount <= wallets[msg.sender].totalBalance);
        
        wallets[msg.sender].totalBalance -= _withdrawalAmount;
        
        int transactionAmount = -1 * int(_withdrawalAmount);

        addTransactionToAccount(msg.sender, transactionAmount);

        _to.transfer(_withdrawalAmount);
    }

    
    // fallback function (not directly interacting with a specific function)
    function () external payable {
        addMoneyToWallet();
    }
    
}