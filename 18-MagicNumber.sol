// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;



contract MagicNum {

  address public solver;

  constructor() {}

  function setSolver(address _solver) public {
    solver = _solver;
  }
}


contract hack {

    MagicNum level18 = MagicNum(0x6D72aA2964000e28cFFB268e0Dee557cD22c231A);
    function run() external{
        bytes memory code = hex"69602A60005260206000F3600052600A6016F3"; //sequence of OPCODES. Can refer this - https://blog.dixitaditya.com/ethernaut-level-18-magicnumber
        address solver;

        assembly {
            solver := create(0, add(code, 0x20), 0x13) //create command is used to create smart contract and returns the address of newly created contract.
        }
        level18.setSolver(solver);
    }
}
