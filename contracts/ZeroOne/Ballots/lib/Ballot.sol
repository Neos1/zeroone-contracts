pragma solidity 0.6.1;

/**
  @title BallotType
  @dev Ballot data type implementation
*/

library BallotType {
  enum BallotStatus { ACTIVE, CLOSED }

  enum BallotResult { NOT_ACCEPTED, POSITIVE, NEGATIVE }

  struct Ballot {
    uint startTime;
    uint starterAddress;
    uint questionId;
    BallotStatus status;
    BallotResult result;
    bytes votingData;
    mapping(address => mapping(address => BallotResult)) votes;
  }

  /**
    @dev set vote of {_user} from {_group}
    @param _group address of group
    @param _user address of user
    @param _descision descision of user
   */
  function setVote(
    Ballot storage _self,
    address _group,
    address _user,
    BallotResult _descision
  )
    internal
    returns (bool status)
  {
    _self.votes[_group][_user] = _descision;
    return true;
  }
}