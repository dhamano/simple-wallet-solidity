# simple-wallet-solidity
Simple solidity wallet that allows multiple administrators (owners) specified during creation. Owners can create sub-wallets/sub-accounts and dispurse money to those sub-wallets. People with access to that sub-wallet account can withdraw funds deposited to pay external accounts.

will be adding a way to need approval before allowing sub-wallets to dispurse funds to named address.

Creating a simple wallet with:
    - [x] set max owners (admins)
    - [x] add/remove owners
    - [x] ability to add/remove funds to/from contract
    - [x] disperse money to sub-accounts
    - [x] pay/withdrawal money to external account from sub-accounts
    - [x] return transactions from accounts
    - [x] admin transfer money between sub-accounts
    - [] approval of funds withdrawal
    - [] testing

Current Test address: N/A (on remix JS VM)