pragma solidity 0.6.1;

/**
  @title BallotType
  @dev Ballot data type implementation
*/

library BallotType {
    enum BallotStatus { CLOSED, ACTIVE }

    enum BallotResult { NOT_ACCEPTED, POSITIVE, NEGATIVE }

    struct Ballot {
        uint startBlock;
        uint startTime;
        uint endTime;
        uint starterGroupId;
        address starterAddress;
        uint questionId; 
        BallotStatus status;
        BallotResult result;
        bytes votingData;
        mapping(address => mapping(address => BallotResult)) votes;
        mapping(address => mapping(address => uint256)) votesWeight;
        mapping(address => mapping(uint => uint256)) descisionWeights;
    }

    /**
     * @dev getting primary info about voting
     * @return startTime
     * @return endTime
     * @return starterGroupId
     * @return starterAddress
     * @return questionId
     * @return status
     * @return result
     * @return votingData
     */
    function getPrimaryInfo(
        Ballot storage _self
    ) 
        internal
        view
        returns (
            uint startTime,
            uint endTime,
            uint starterGroupId,
            address starterAddress,
            uint questionId,
            BallotStatus status,
            BallotResult result,
            bytes storage votingData
        )
    {
        return (
            _self.startTime,
            _self.endTime,
            _self.starterGroupId,
            _self.starterAddress,
            _self.questionId,
            _self.status,
            _self.result,
            _self.votingData
        );
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
        BallotResult _descision,
        uint256 _voteWeight
    )
        internal
        returns (bool status)
    {
        _self.votes[_group][_user] = _descision;
        _self.votesWeight[_group][_user] = _voteWeight;
        _self.descisionWeights[_group][uint(_descision)] = _self.descisionWeights[_group][uint(_descision)] + _voteWeight;

        return true;
    }

    /**
     * @dev get user vote in this voting
     * @param _group address of group
     * @param _user address of user
     * @return userVote
     */
    function getUserVote(
        Ballot storage _self,
        address _group,
        address _user
    )
        internal
        view
        returns (BallotResult userVote) 
    {
        userVote = _self.votes[_group][_user];
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
        return BallotResult.POSITIVE;
    }

    /**
     * @dev close ballot by calculating result and setting status "CLOSED"
     * @param _self ballot
     */
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


    function validate(
        //Ballot memory _self
    )
        internal
        pure
        returns (bool)
    {
        return true;
    }
}
