# Vault Ethernaut

## Goals

=> Unlock the vault to pass the level!

### Hints

- None

### Solution

- Since nothing on the blockchain is really private, the private keyword on the password variable doesn't really do much, we can for example just use `web3.eth.getStorageAt(address, storageSlot)` to access the given sotrage slot in our case `web3.eth.getStorageAt(contract.address, 1)` which will return us the password

### Contract

No contract needed
