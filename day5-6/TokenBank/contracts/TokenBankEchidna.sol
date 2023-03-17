pragma solidity ^0.4.21;

import "./TokenBank.sol";

// interface ITokenReceiver {
//     function tokenFallback(address from, uint256 value, bytes data) external;
// }

contract TokenBankEchidna {
    TokenBankChallenge tokenBank;
    SimpleERC223Token token;

    constructor() public {
        // owner is 0x30000 since deployer
        tokenBank = new TokenBankChallenge(address(0x10000));
        // owner is echidna (address(this))
        token = new SimpleERC223Token();
    }

    function test_drain() public view {
        assert(token.balanceOf(address(tokenBank)) > 999999 ether);
    }
}
