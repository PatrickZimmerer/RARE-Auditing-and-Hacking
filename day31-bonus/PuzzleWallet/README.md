# Puzzle Wallet Ethernaut

## Goals

=> You'll need to hijack this wallet to become the admin of the proxy.

### Hints

- Understanding how delegatecall works and how msg.sender and msg.value behaves when performing one.

- Knowing about proxy patterns and the way they handle storage variables.

### Solution

- By setting the second storage variable `maxBalance` which is `admin` in the proxy contract to our address by typecasting it like that `uint256(uint160(YOURADDRESS))`, you change the owner of the PuzzleWallet contract to the given address and will win the challenge.

- The only functions giving us the opportunity to change `maxBalance` are `init()` & `setMaxBalance()`, since the `init()` function checks for the `maxBalance` variable, this will not work, so we need to somehow get around the `onlyWhitelisted` modifier and achieve that `address(this).balance == 0`

### Attacker Contract

```solidity
contract Attacker {
}
```
