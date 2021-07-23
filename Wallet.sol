pragma solidity ^0.5.17;

import "./OwnedBy.sol";

contract Wallet is OwnedBy {
    
    constructor(uint8 maxNumOwners) OwnedBy(maxNumOwners) public {}

    event WalletChange(address indexed _changedFor, address indexed _changedBy, uint _oldAmount, uint _newAmount);
    event WalletWithdrawal(address indexed _to, address indexed _changedBy, uint _oldAmount, uint _newAmount);
    
    struct Transactions {
        int amount;
        address fromAccount;
        address toAccount;
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
    
    function addTransactionToMainAccount(address _fromAccount, address _toAccount, int _amount) internal {
        Transactions memory transaction = Transactions(int(_amount), _fromAccount, _toAccount, block.timestamp);
        
        mainTransactions.push(transaction);
    }
    
    function addTransactionToAccount(address _account, address _fromAccount, address _toAccount, int _amount) internal {
        Transactions memory transaction = Transactions(_amount, _fromAccount, _toAccount, block.timestamp);
        
        wallets[_account].transactions[wallets[_account].numPayments] = transaction;
        wallets[_account].numPayments++;
    }
    
    function addMoneyToWallet() public payable {
        assert(walletBalance + msg.value >= walletBalance);
        emit WalletChange(address(this), msg.sender, walletBalance, walletBalance + msg.value);
        walletBalance += msg.value;

        
        addTransactionToMainAccount(msg.sender, address(this), int(msg.value));
    }
    
    function withdrawMoney(address payable _to, uint _withdrawalAmount) public isAmountValid(_withdrawalAmount) {
        assert(wallets[msg.sender].totalBalance - _withdrawalAmount <= wallets[msg.sender].totalBalance);
        
        emit WalletWithdrawal(_to, msg.sender, wallets[msg.sender].totalBalance, wallets[msg.sender].totalBalance - _withdrawalAmount);

        wallets[msg.sender].totalBalance -= _withdrawalAmount;

        addTransactionToAccount(msg.sender, msg.sender, _to, -1 * int(_withdrawalAmount));

        _to.transfer(_withdrawalAmount);
    }
    
    function getTransaction(uint _index) public view returns(int, address, address, uint) {
        Transactions memory theTransaction = wallets[msg.sender].transactions[_index];

        int amount = theTransaction.amount;
        address fromAccount = theTransaction.fromAccount;
        address toAccount = theTransaction.toAccount;
        uint time = theTransaction.timestamps;

        return (amount, fromAccount, toAccount, time);
    }
    
    function getAllTransactions() public view returns(int[] memory, address[] memory, address[] memory, uint[] memory) {
        uint _length = wallets[msg.sender].numPayments;
        int[] memory amount = new int[](_length);
        address[] memory fromAccount = new address[](_length);
        address[] memory toAccount = new address[](_length);
        uint[] memory timestamps = new uint[](_length);

        for(uint i = 0; i < _length; i++) {
            amount[i] = wallets[msg.sender].transactions[i].amount;
            fromAccount[i] = wallets[msg.sender].transactions[i].fromAccount;
            toAccount[i] = wallets[msg.sender].transactions[i].toAccount;
            timestamps[i] = wallets[msg.sender].transactions[i].timestamps;
        }
        
        return (amount, fromAccount, toAccount, timestamps);
    }

    
    // fallback function (not directly interacting with a specific function)
    function () external payable {
        addMoneyToWallet();
    }
    
}