# Token whale Capture the ether

## Goals

=> Find a way to accumulate at least 1,000,000 tokens to solve this challenge.

### Hints

- None

### Solution

- The vulnerability lies in the `_transfer()` function which subtracts the balanceOf msg.sender without checking if the balance of him is sufficient, so by approving another user (let's call him user B) for one token as the player, then call the transferFrom function `transferFrom()` as user B and just send 1 token to any address his balance will underflow and all of a sudden user B has a balance of 2 \*\* 256 - 1 and can transfer the tokens to our player.

- I used Echidna for this and it found a similiar solution

### Attacker Contract

```solidity
// SPDX-License Identifier:MIT

pragma solidity 0.5.0;

import "./TokenWhale.sol";

contract TokenWhaleEchidna is TokenWhaleChallenge {
    TokenWhaleChallenge public token;

    constructor() public TokenWhaleChallenge(msg.sender) {}

    function echidna_test_balance() public view returns (bool) {
        return !isComplete();
    }

    function testTransfer(address, uint256) public view {
        // Pre conditions
        // actions
        // Check that isComplete function returns true or false as expected
        assert(!isComplete());
    }
}
```
