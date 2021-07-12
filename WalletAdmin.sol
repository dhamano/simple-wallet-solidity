pragma solidity ^0.5.17;

import "./Wallet.sol";

contract AdminFunctions is Wallet  {
    
    constructor(uint8 maxNumOwners) Wallet(maxNumOwners) public {}
    
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
        
        walletBalance -= _amount;
        _to.transfer(_amount);
    }
    
    function dispurseMoney(address _to, uint _amount) public payable requireOwner isWalletBalanceValid(_amount) {
        assert(walletBalance - _amount <= walletBalance);
        assert(wallets[_to].totalBalance + _amount >= wallets[_to].totalBalance);
        
        walletBalance -= _amount;
        wallets[_to].totalBalance += _amount;
        
        addTransactionToMainAccount(-1 * int(_amount));
        addTransactionToAccount(_to, int(_amount));
    }
    
    function reclaimMoney(address _from, uint _amount) public payable requireOwner isAmountValidAdmin(_from, _amount) {
        assert(wallets[_from].totalBalance - _amount <= wallets[_from].totalBalance);
        assert(walletBalance + _amount >= walletBalance);
        
        wallets[_from].totalBalance -= _amount;
        walletBalance += _amount;
        
        addTransactionToMainAccount(int(_amount));
        addTransactionToAccount(_from, -1 * int(_amount));
    }
    
    function transferMoneyBetweenAccounts(address _from, address _to, uint _amount) public isAmountValidAdmin(_from, _amount) {
        assert(wallets[_from].totalBalance - _amount <= wallets[_from].totalBalance);
        assert(wallets[_to].totalBalance + _amount >= wallets[_to].totalBalance);

        addTransactionToAccount(_from, -1 * int(_amount));
        addTransactionToAccount(_to, int(_amount));
    }
    
    function getMainTransaction(uint _index) public view returns(int, uint) {
        Transactions memory theTransaction = mainTransactions[_index];
        int amount = theTransaction.amount;
        uint time = theTransaction.timestamps;
        return (amount, time);
    }
    
    function getAllmainTransactions() public view returns(int[] memory, uint[] memory) {
        int[] memory amount = new int[](mainTransactions.length);
        uint[] memory timestamps = new uint[](mainTransactions.length);
        for(uint i = 0; i < mainTransactions.length; i++) {
            amount[i] = mainTransactions[i].amount;
            timestamps[i] = mainTransactions[i].timestamps;
        }
        
        return (amount, timestamps);
    }
}