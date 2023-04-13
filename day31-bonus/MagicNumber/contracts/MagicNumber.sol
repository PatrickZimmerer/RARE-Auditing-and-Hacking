// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MagicNum {
    address public solver;

    constructor() {}

    function setSolver(address _solver) public {
        solver = _solver;
    }

    /*
    ____________/\\\_______/\\\\\\\\\_____        
     __________/\\\\\_____/\\\///////\\\___       
      ________/\\\/\\\____\///______\//\\\__      
       ______/\\\/\/\\\______________/\\\/___     
        ____/\\\/__\/\\\___________/\\\//_____    
         __/\\\\\\\\\\\\\\\\_____/\\\//________   
          _\///////////\\\//____/\\\/___________  
           ___________\/\\\_____/\\\\\\\\\\\\\\\_ 
            ___________\///_____\///////////////__
  */
}

// Store 42 in Memory
// PUSH1 2a => 602a // value = 42
// PUSH1 00 => 6000// at location 00
// MSTORE   => 52 // Store at location 00 the value 42 (2a)
// PUSH1 20 => 6020 // 32
// PUSH1 00 => 6000 // 00
// RETURN f3 => returns from byte 0 to byte 32
// = 602a 6000 52 6020 6000 f3
// EVM Playground after stepping through our runtime code =>
// memory: 000000000000000000000000000000000000000000000000000000000000002a => 42
// return value: 000000000000000000000000000000000000000000000000000000000000002a => 42

// runtime code: 602a60005260206000f3 => store it in the 0th slot
// PUSH10 69  => 69602a60005260206000f3 => 10 bytes (length of runtimecode)
// PUSH1 00 => 6000
// MSTORE   => 52 (get stored as 32 bytes so 0x0000000...runtime code)
// => 69602a60005260206000f3 6000 52

// PUSH1 0a => 600a => 10 bytes
// PUSH1 60 => 6016 => starting at 22 bytes offset
// RETURN   => f3 //return s 10 bytes starting after the 22nd byte (padded with zeros)
// => thats the runtime code that returns 42
// = 600a 6016 f3

// => 69602a60005260206000f3 6000 52 600a 6000 52 600a 6016 f3

// => 69602a60005260206000f3600052600a6016f3
// EVM Playground after stepping through our bytecode =>
// memory: 00000000000000000000000000000000000000000000602a60005260206000f3 => our runtime code with padding
// return value: 602a60005260206000f3 => our function that returns 42

// Target contract: 0x19A6769F1De69b493028b86625a5229406fD9872
contract DeployBytecode {
    constructor(MagicNum target) {
        bytes memory bytecode = hex"69602a60005260206000f3600052600a6016f3";
        address addr;

        assembly {
            addr := create(0, add(bytecode, 0x20), 0x90)
        }
        require(addr != address(0));
        // contract created succesfully
        target.setSolver(addr);
    }
}
