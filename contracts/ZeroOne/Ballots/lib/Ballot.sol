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
        mapping(address => mapping(address => uint256)) tokenReturns;
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
        _self.tokenReturns[_group][_user] = 0;
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
     * @dev close ballot by calculating result and setting status "CLOSED"
     * @param _self ballot
     */
    function close(
        Ballot storage _self
    )
        internal
    {
       _self.status = BallotStatus.CLOSED;
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
