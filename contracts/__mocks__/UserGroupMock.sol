

pragma solidity 0.6.1;
pragma experimental ABIEncoderV2;

import "../ZeroOne/UserGroups/lib/UserGroup.sol";

/**
  @title UserGroupMock
  @dev mock for testing UserGroup lib
 */
contract UserGroupMock {
  using UserGroup for UserGroup.Group;
  UserGroup.Group group;
  
  constructor(UserGroup.Group memory _group) public {
    require(_group.validate(), "Incorrect UserGroup");
    group = _group;
  }

  /**
    @dev method for testing getAdmin() method of user group
    @return admin
   */
  function testGetAdmin() 
    public
    view
    returns(address admin)
  {
    return group.getAdmin();
  } 

  /**
    @dev method for testing getAdmin() method of user group
    @return totalSupply
   */
  function testGetTotalSupply() 
    public
    view
    returns(uint256 totalSupply)
  {
    return group.getTotalSupply();
  } 
}

