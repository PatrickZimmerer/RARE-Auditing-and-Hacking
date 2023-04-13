# Magic Number Ethernaut

## Goals

=> To solve this level, you only need to provide the Ethernaut with a Solver, a contract that responds to whatIsTheMeaningOfLife() with the right number.

=> Easy right? Well... there's a catch.

=> The solver's code needs to be really tiny. Really reaaaaaallly tiny. Like freakin' really really itty-bitty tiny: 10 opcodes at most.

### Hints

- Perhaps its time to leave the comfort of the Solidity compiler momentarily, and build this one by hand O_o. That's right: Raw EVM bytecode.

### Solution

- Generate runtime code that returns 42 by storing the value 42 at memory location 0 and then returns the first (0th) memory location so bytes 0 - 32 as following

- This will give us the runtime code we need to store `602a60005260206000f3`

- Generate our Bytecode contract that stores our runtime code in memory and then returns the last 10 bytes, since the evm stores in 32bytes and just pads 22bytes in Zeros to the left, when being called (which contains our runtime code that returns 42)

```assembly
// runtime code: 602a60005260206000f3 => store it in the 0th slot
// PUSH10 69  => 69602a60005260206000f3 => 10 bytes (length of runtimecode)
// PUSH1 00 => 6000
// MSTORE   => 52 (get stored as 32 bytes so 0x0000000...runtime code)
// => 69602a60005260206000f3 6000 52

// PUSH1 0a => 600a => 10 bytes
// PUSH1 60 => 6016 => starting at 22 bytes offset
// RETURN   => f3 //return s 10 bytes starting after the 22nd byte (padded with zeros)
```

- This results in this bytecode: `69602a60005260206000f3600052600a6016f3`
- After running through all steps in the EVM playground it indeed retuns us our runtime code

```solidity
// memory: 00000000000000000000000000000000000000000000602a60005260206000f3 => our runtime code with padding
// return value: 602a60005260206000f3 => our function that returns 42
```

- Now we just need to pass in our bytecode into a bytes variable and deploy a contract with the create method with:
  => a value of 0
  => an offest of the bytecode + 32 bytes(0x20) since in the first slot (0x00) the length of the bytecode is stored
  => length of the bytecode => 19 bytes => 0x13

- Check if the contract got created and then use the `setSolver()` function of the target contract

### Attacker Contract

```solidity
contract DeployBytecode {
    constructor(MagicNum target) {
        bytes memory bytecode = hex"69602a60005260206000f3600052600a6016f3";
        address addr;

        assembly {
            addr := create(0, add(bytecode, 0x20), 0x13)
        }
        require(addr != address(0));
        // contract created succesfully
        target.setSolver(addr);
    }
}
```
