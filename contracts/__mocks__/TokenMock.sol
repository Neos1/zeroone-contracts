pragma solidity 0.6.1;

contract TokenMock {
  uint256 private _totalSupply;
  string private _symbol;
  string private _name;
  address private _owner;

  constructor() public {
    _totalSupply = 2000;
    _name = "Test";
    _symbol = "TST";
    _owner = msg.sender;
  }

  function totalSupply() public view returns(uint256) {
    return _totalSupply;
  }
  
  function owner() public view returns(address) {
    return _owner;
  }
}