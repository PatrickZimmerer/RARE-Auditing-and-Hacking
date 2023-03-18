// SPDX-License Identifier:MIT

pragma solidity 0.5.0;

import "./TokenWhale.sol";

contract TokenWhaleEchidna is TokenWhaleChallenge {
    TokenWhaleChallenge public token;

    constructor() public TokenWhaleChallenge(msg.sender) {}

    function echidna_test_balance() public view returns (bool) {
        return !isComplete();
    }

    function testTransfer(address, uint256) public view {
        assert(!isComplete());
    }
}
