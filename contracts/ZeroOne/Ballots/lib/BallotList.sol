pragma solidity 0.6.1;

import "./Ballot.sol";

/**
  @title BallotList
  @dev stores votings
 */
library BallotList {
  using BallotType for BallotType.Ballot;

  struct List {
    BallotType.Ballot[] list;
  }

  /**
    @dev add voting to list
    @param _voting
    @return id
   */
  function addVoting(
    List storage _self,
    BallotType.Ballot memory _voting
  )
    internal
    returns (uint id)
  {
    _self.list.push(_voting);
    return _self.list.length - 1;
  }

  /**
    @dev checks id existance
    @param _id id
    @return valid
   */
  function checkId(
    List storage _self,
    uint _id
  )
    internal
    view
    returns (bool valid)
  {
    return _self.list.length > _id;
  }

}
