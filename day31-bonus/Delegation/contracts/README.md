# Delegation Ethernaut

## Goals

=> Take ownership of the contract

### Hints

- None

### Solution

- You just need to call the pwn function from the delegate contract, since with delegate call you call a function with the storage of another contract we can modify the storage of the target contract with a function of our "Attacker" contract
