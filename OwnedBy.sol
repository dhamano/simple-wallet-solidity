pragma solidity ^0.5.17;

contract OwnedBy {
    mapping(address => bool) private owners;
    address[] private ownerAddresses;
    uint8 public maxOwners;
    
    constructor(uint8 maxNumOwners) public {
        owners[msg.sender] = true;
        ownerAddresses.push(msg.sender);
        maxOwners = maxNumOwners;
    }
    
    modifier requireOwner() {
        require(owners[msg.sender], "You are not an owner.");
        _;
    }
    
    function addOwner(address _anotherOwner) public requireOwner {
        require(ownerAddresses.length < maxOwners, "Max owners reached");
        require(!owners[_anotherOwner], "Owner already added");
        ownerAddresses.push(_anotherOwner);
        owners[_anotherOwner] = true;
    }
    
    function removeOwner(address _remove) public requireOwner {
        require(ownerAddresses.length > 1, "Last owner, cannot remove.");
        uint8 j = 0;
        for(uint8 i = 0; i < ownerAddresses.length; i++) {
            if(ownerAddresses[i] != _remove) {
                ownerAddresses[j] = ownerAddresses[i];
                j++;
            } else {
                delete ownerAddresses[i];
            }
        }
        ownerAddresses.length--;
        owners[_remove] = false;
    }
    
    function getOwners() public view returns(address[] memory){
        return ownerAddresses;
    }
}