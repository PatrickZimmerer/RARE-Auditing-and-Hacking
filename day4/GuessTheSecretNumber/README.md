# Guess the secret number Capturetheether

## Goals

=> Guess the number by reversing a cryptographic hash

### Solution

- There is only 256 variables to check for so you just need to loop through numbers 0 - 255 and compare the hash of those numbers to the answerHash this should be done offChain to save some gas but when setting the gas limit to the maximum in remix `2 ** 64 - 1` is sufficient and easier to test, so I wrote the exploit on chain, when a larger uint would've been used for example uint256 it would've been computationally impossible to guess the right number.

### Attacker Contract

```solidity
contract Hack {
    bytes32 answerHash = 0xdb81b4d58595fbbbb592d3661a34cdca14d7ab379441400cbfa1b78bc447c365;

    function getAnswer() external view returns(uint8){
        for(uint8 i = 0; i < 256; i++){
            if(keccak256(i) == answerHash){
                return i;
            }
        }
    }
}
```
