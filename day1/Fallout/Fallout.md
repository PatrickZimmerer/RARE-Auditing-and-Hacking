# Fal1out Ethernaut

## Goals

=> Claim ownership of the contract

- Need to know: In Solidity the contract name is a reserved word which can be used as `function ContractName` to serve as a constructor.
- Here no exploit code had to be written since the constructor function Fal1out doesn't match the contract title Fallout, this typo makes the contract vulnerable since anybody can just call the Fal1out function and claim ownership.
