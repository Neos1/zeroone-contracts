pragma solidity 0.6.1;

import "../../../__vendor__/IERC20.sol";
import "zeroone-voting-vm/contracts/ZeroOneVM.sol";

/**
  @title BallotType
  @dev Ballot data type implementation
*/

library BallotType {
    using ZeroOneVM for ZeroOneVM.Ballot;

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
        bytes votingData;
        mapping(address => mapping(address => VM.Vote)) votes;
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
        VM.Vote _descision
    )
        internal
        returns (bool status)
    {        
        require(_self.endTime > block.timestamp, "Votes recieving are closed");
        require(
            _self.status != BallotStatus.CLOSED, 
            "Voting is closed, you must start new voting before vote"
        );

        IERC20 group = IERC20(_group);
        uint256 voteWeight = group.balanceOf(_user);
        require(group.transferFrom(_user, address(this), voteWeight));

        _self.votes[_group][_user] = _descision;
        _self.votesWeight[_group][_user] = voteWeight;
        _self.descisionWeights[_group][uint(_descision)] = _self.descisionWeights[_group][uint(_descision)] + voteWeight;
        return true;
    }

    function updateUserVote(
        Ballot storage _self,
        address _group,
        address _user,
        uint256 _newVoteWeight
    )
        internal
        returns (bool status)
    {
        uint256 oldVoteWeight = _self.votesWeight[_group][_user];
        uint index = uint(_self.votes[_group][_user]);
        uint256 oldDescisionWeight = _self.descisionWeights[_group][index];

        if (_self.status == BallotStatus.ACTIVE) {
            _self.votesWeight[_group][_user] = _newVoteWeight;
            _self.descisionWeights[_group][index] = oldDescisionWeight - oldVoteWeight + _newVoteWeight;
            if (_newVoteWeight == 0) {
                _self.votes[_group][_user] = VM.Vote.UNDEFINED;
            }
        }
        return true;
    }

    function getGroupVotes(
        Ballot storage _self,
        address _group
    )
        internal 
        view
        returns(
            uint256 positive,
            uint256 negative,
            uint256 totalSupply
        ) 
    {
        positive = _self.descisionWeights[_group][uint(VM.Vote.ACCEPTED)];
        negative = _self.descisionWeights[_group][uint(VM.Vote.DECLINED)];
        totalSupply = IERC20(_group).totalSupply();
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
        returns (VM.Vote userVote) 
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
     * @return success
     */
    function setResult(
        Ballot storage _self
    )
        internal
        returns (bool success)
    {
        require(setStatus(_self, BallotStatus.CLOSED), "Problem with setting status");
        return true;
    }

    /**
     * @dev calculates result of voting
     */
     // TODO Implement this after ready formula parser
    function calculateResult()
        internal
        pure
        returns (VM.Vote)
    {
        return VM.Vote.ACCEPTED;
    }

    /**
     * @dev close ballot by calculating result and setting status "CLOSED"
     * @param _self ballot
     */
    function closeVoting(
        Ballot storage _self
    )
        internal
        returns (VM.Vote result)
    {
        VM.Vote _result = calculateResult();
        setResult(_self);
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
