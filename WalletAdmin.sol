pragma solidity ^0.5.17;

import "./Wallet.sol";

contract AdminFunctions is Wallet  {
    
    constructor(uint8 maxNumOwners) Wallet(maxNumOwners) public {}
    
    event DispurseMoneyEvent(address indexed _from, address indexed _to, uint _mainWalletOldAmount, uint _mainWalletAmount, uint _walletOldAmount, uint _walletAmount);
    
    modifier isWalletBalanceValid(uint _amount) {
        require(walletBalance >= _amount, "Not enough funds in wallet");
        _;
    }
    
    modifier isAmountValidAdmin(address _to, uint _amount) {
        require(wallets[_to].totalBalance >= _amount, "Not enough funds in account");
        _;
    }
    
    function getContractAmount() public view requireOwner returns (uint _amount) {
        return address(this).balance;
    }
    
    function withdrawMoneyFromContract(address payable _to, uint _amount) public requireOwner isWalletBalanceValid(_amount) {
        assert(walletBalance - _amount <= walletBalance);
        
        emit WalletChange(address(this), msg.sender, walletBalance, walletBalance - _amount);
        
        walletBalance -= _amount;
        _to.transfer(_amount);
    }
    
    function dispurseMoney(address _to, uint _amount) public payable requireOwner isWalletBalanceValid(_amount) {
        assert(walletBalance - _amount <= walletBalance);
        assert(wallets[_to].totalBalance + _amount >= wallets[_to].totalBalance);
        
        emit DispurseMoneyEvent(_to, msg.sender, walletBalance, walletBalance - _amount, wallets[_to].totalBalance, wallets[_to].totalBalance + _amount);
        
        walletBalance -= _amount;
        wallets[_to].totalBalance += _amount;
        
        addTransactionToMainAccount(msg.sender, _to, -1 * int(_amount));
        addTransactionToAccount(_to, msg.sender, _to, int(_amount));
    }
    
    function reclaimMoney(address _from, uint _amount) public payable requireOwner isAmountValidAdmin(_from, _amount) {
        assert(wallets[_from].totalBalance - _amount <= wallets[_from].totalBalance);
        assert(walletBalance + _amount >= walletBalance);
        
        emit DispurseMoneyEvent(_from, msg.sender, walletBalance, walletBalance + _amount, wallets[_from].totalBalance, wallets[_from].totalBalance - _amount);
        
        wallets[_from].totalBalance -= _amount;
        walletBalance += _amount;
        
        addTransactionToMainAccount(_from, address(this), int(_amount));
        addTransactionToAccount(_from, _from, address(this), -1 * int(_amount));
    }
    
    function transferMoneyBetweenAccounts(address _from, address _to, uint _amount) public requireOwner isAmountValidAdmin(_from, _amount) {
        assert(wallets[_from].totalBalance - _amount <= wallets[_from].totalBalance);
        assert(wallets[_to].totalBalance + _amount >= wallets[_to].totalBalance);
        
        emit WalletChange(_to, _from, wallets[_to].totalBalance, wallets[_to].totalBalance + _amount);
        emit WalletChange(_from, _to, wallets[_from].totalBalance, wallets[_from].totalBalance - _amount);
        
        wallets[_from].totalBalance -= _amount;
        wallets[_to].totalBalance += _amount;

        addTransactionToAccount(_from, _from, _to, -1 * int(_amount));
        addTransactionToAccount(_to, _from, _to, int(_amount));
    }
    
    function getMainTransaction(uint _index) public view returns(int, address, address, uint) {
        Transactions memory theTransaction = mainTransactions[_index];
        int amount = theTransaction.amount;
        address fromAccount = theTransaction.fromAccount;
        address toAccount = theTransaction.toAccount;
        uint time = theTransaction.timestamps;
        return (amount, fromAccount, toAccount, time);
    }
    
    function getAllmainTransactions() public view returns(int[] memory, address[] memory, address[] memory, uint[] memory) {
        int[] memory amount = new int[](mainTransactions.length);
        address[] memory fromAccount = new address[](mainTransactions.length);
        address[] memory toAccount = new address[](mainTransactions.length);
        uint[] memory timestamps = new uint[](mainTransactions.length);
        for(uint i = 0; i < mainTransactions.length; i++) {
            amount[i] = mainTransactions[i].amount;
            fromAccount[i] = mainTransactions[i].fromAccount;
            toAccount[i] = mainTransactions[i].toAccount;
            timestamps[i] = mainTransactions[i].timestamps;
        }
        
        return (amount, fromAccount, toAccount, timestamps);
    }
}