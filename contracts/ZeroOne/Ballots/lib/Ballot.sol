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
        uint starterGroupId;
        uint starterAddress;
        uint questionId;
        BallotStatus status;
        BallotResult result;
        bytes votingData;
        mapping(address => mapping(address => BallotResult)) votes;
        mapping(address => mapping(address => uint256)) votesWeight;
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

    /**
     * @dev set status in voting
     * @param _status new Voting status 
     * @return success
     */
    function setStatus(
        Ballot storage _self,
        BallotStatus _status
    )
        internal
        returns (bool success)
    {
        _self.status = _status;
        return _self.status == _status;
    }

    /**
     * @dev set result and status "Closed" to voting
     * @param _result calculated result of voting
     * @return success
     */
    function setResult(
        Ballot storage _self,
        BallotResult _result
    )
        internal
        returns (bool success)
    {
        require(setStatus(_self, BallotStatus.CLOSED), "Problem with setting status");
        _self.result = _result;
        return _self.result == _result;
    }

    /**
     * @dev calculates result of voting
     */
     // TODO Implement this after ready formula parser
    function calculateResult()
        internal
        pure
        returns (BallotResult)
    {
        return BallotResult.NOT_ACCEPTED;
    }

    function closeVoting(
        Ballot storage _self
    )
        internal
        returns (BallotResult result)
    {
        BallotResult _result = calculateResult();
        setResult(_self, _result);
        return _result;
    }
}
