# Guess the random number Capturetheether

## Goals

=> Guess the fairly random number

- There is nop randomness since you can get the Blocknumber & the Blockhash + the timestamp on etherscan and you just need to `abi.encodePacked()` both of those values then you can copy the rest of the function in the constructor, the blockHash were looked up on etherscan aswell as the timestamp and stored in variables for readability reasons, the contract should look like this:

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
