pragma solidity 0.6.1;
pragma experimental ABIEncoderV2;

import "./lib/Ballot.sol";
import "./lib/BallotList.sol";
import "../Questions/QuestionsWithGroups.sol";
import "../UserGroups/UserGroups.sol";

/**
 * @title Ballots
 * @dev stores Ballots
 */
contract Ballots is QuestionsWithGroups, UserGroups {
    using BallotList for BallotList.List;
    using BallotType for BallotType.Ballot;

    BallotList.List ballots;


    event VotingStarted(uint votingId, uint questionId);

    event VotingEnded(uint votingId, BallotType.BallotResult descision);

    event UserVote(address group, address user, BallotType.BallotResult descision);

    /**
     * @notice reverts on non-existing ballot id
     * @param _id ballot id
     */
    modifier ballotExist(
        uint _id
    ) {
        require(
            ballots.checkId(_id),
            "Provided index out of bounds"
        );
        _;
    }

    modifier noActiveVotings() {
        uint length = ballots.list.length;
        require(length > 0
            ? ballots.list[length - 1].status != BallotType.BallotStatus.ACTIVE
            : true,
            "You have active voting"
        );
        _;
    }

    modifier userNotVoted(
        address _group,
        address _user
    ) {
        uint _id = ballots.list.length - 1;

        require(
            ballots.list[_id].votes[_group][_user] == BallotType.BallotResult.NOT_ACCEPTED,
            "User already vote"
        );
        _;
    }

    modifier groupIsAllowed(
        uint _questionId,
        uint _groupId
    ) {
        QuestionType.Question memory question = getQuestion(_questionId);
        require(
            _groupId == question.groupId,
            "This group have no permissions to start voting with this question"
         );
        _;
    }
    constructor() public {}

    /**
     * @dev creates new Ballot in list
     */
    function startVoting(
        BallotList.BallotSimple memory _votingPrimary
    )
        public
        noActiveVotings()
        questionExists(_votingPrimary.questionId)
        groupIsAllowed(
            _votingPrimary.questionId,
            _votingPrimary.starterGroupId
        )
        returns (uint id)
    {
        _votingPrimary.endTime = block.timestamp + questions.list[_votingPrimary.questionId].timeLimit;
        id = ballots.add(_votingPrimary);
        emit VotingStarted(id, _votingPrimary.questionId);
    }

    /**
     * @dev getting the voting by id
     */
    function getVoting(
        uint _id
    )
        public
        view
        ballotExist(_id)
        returns (
            uint startTime,
            uint endTime,
            uint starterGroupId,
            address starterAddress,
            uint questionId,
            BallotType.BallotStatus status,
            BallotType.BallotResult result,
            bytes memory votingData
        )
    {
        return ballots.list[_id].getPrimaryInfo();
    }

    /**
     * @dev return amount of votings
     * @return amount
     */
    function getVotingsAmount()
        public
        view
        returns (uint amount)
    {
        return ballots.list.length;
    }

    function setVote(
        address _group,
        address _user,
        BallotType.BallotResult _descision,
        uint256 _voteWeight
    ) 
        public
        userNotVoted(
            _group,
            _user
        )
        returns (bool success)
    {
        uint votingId = ballots.list.length - 1;
        require(ballots.list[votingId].endTime > block.timestamp, "Votes recieving are closed");
        require(
            ballots.list[votingId].status != BallotType.BallotStatus.CLOSED, 
            "Voting is closed, you must start new voting before vote"
            );
        ballots.list[votingId].setVote(_group, _user, _descision, _voteWeight);
        emit UserVote(_group, _user, _descision);
        return true;
    }

    /**
     * @dev closes last voting in list
     * @return descision
     */
    function closeVoting() 
        public
        returns (
            BallotType.BallotResult descision
        )
    {
        uint votingId = ballots.list.length - 1;
        require(ballots.list[votingId].endTime < block.timestamp, "Time is not over yet");
        descision = ballots.list[votingId].closeVoting();
        emit VotingEnded(votingId, descision);
    }
}
