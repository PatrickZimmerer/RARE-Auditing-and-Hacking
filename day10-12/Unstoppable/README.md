# #1 Unstoppable Damn Vulnerable Defi

## Goals

=> There’s a tokenized vault with a million DVT tokens deposited. It’s offering flash loans for free, until the grace period ends.

=> To pass the challenge, make the vault stop offering flash loans.

=> You start with 10 DVT tokens in balance.

### Hints

- None

### Solution

- To stop the pool from offering the flash loans we need to check the `flashLoan()` function of the UnstoppableVault contract and see if we can break this, a few concerns came up when I saw it, a lot of strict equality checks and external contract calls with no reentrancy guards, after analyzing the weakness is obvious since the contract checks for `if (convertToShares(totalSupply) != balanceBefore)` checking by strict equality with ether / tokens is always dangerous (slither also complains when you are doing that), so we just need to send any amount of tokens to the contract !!not through the deposit function!! and this will throw off the calculations and always revert this: `Error provided by the contract: InvalidBalance`

### Attacker Contract

No contract needed
