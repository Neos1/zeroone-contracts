pragma solidity 0.6.1;


/**
 * @title Group
 * @dev User group data type implementation
 */
library UserGroup {
  enum Type {ERC20, CUSTOM}

  struct Group {
    string name;
    address groupAddress;
    Type groupType;
  }

  /**
   * @notice validates group
   * @param _group group
   * @return valid
  */
  function validate(
    Group memory _group
  )
    internal
    pure
    returns (bool valid)
  {
    return (
      _group.groupAddress != address(0)
    );
  }
}
