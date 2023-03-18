// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "./Token.sol";

contract TokenEchidna {
    Token token;

    constructor() public {
        token = new Token(20);
    }

    function echidna_testOverflow() public view returns (bool) {
        return token.balanceOf(address(this)) < 20;
    }

    function testOverflow(address _to, uint _value) public {
        require(_value > 0);
        token.transfer(_to, _value);
        assert(token.balanceOf(address(this)) < 20);
    }
}
