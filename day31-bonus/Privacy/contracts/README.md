# Privacy Ethernaut

## Goals

=> Unlock this contract to beat the level.

### Hints

- Understanding how storage works

- Understanding how parameter parsing works

- Understanding how casting works

- Remember that metamask is just a commodity. Use another tool if it is presenting problems. Advanced gameplay could involve using remix, or your own web3 provider.

### Solution

- Since nothing on the blockchain is really private, and the key is stored on chain, we can for example just use `web3.eth.getStorageAt(address, storageSlot)` to access the given sotrage slot in our case `web3.eth.getStorageAt(contract.address, 5)` which will return us the key

- Storage Slot 5 can be calculated like:

0. Slot => Boolean
1. Slot uint256
2. Slot uint8 uint8 uint16 packed in that slot
3. Slot first item of the data array
4. Slot second item of the data array
5. Slot third item of the data array (index 2)

- Then just pass in the returned value from that storage slot as a bytes16 to pass the challenge

### Attacker Contract

```solidity
contract Hack {
}
```
