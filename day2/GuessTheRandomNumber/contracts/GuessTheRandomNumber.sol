pragma solidity ^0.4.21;

contract Hack {
    bytes32 public previousBlockHash =
        0xaf522205a688dbca66076fb9018238a615472ee70c411ecb9e882f77d874ad40;
    uint public previousTimestamp = 1678819296000;

    function guessNum() external view returns (uint8) {
        return
            uint8(
                keccak256(
                    abi.encodePacked(previousBlockHash, previousTimestamp)
                )
            );
    }
}

contract GuessTheRandomNumberChallenge {
    uint8 answer;

    constructor() public payable {
        require(msg.value == 1 ether);
        answer = uint8(keccak256(block.blockhash(block.number - 1), now));
    }

    function isComplete() public view returns (bool) {
        return address(this).balance == 0;
    }

    function guess(uint8 n) public payable {
        require(msg.value == 1 ether);

        if (n == answer) {
            msg.sender.transfer(2 ether);
        }
    }
}
