pragma solidity 0.6.1;
pragma experimental ABIEncoderV2;

import "./lib/Ballot.sol";
import "./lib/BallotList.sol";
import "../Questions/QuestionsWithGroups.sol";
import "../UserGroups/UserGroups.sol";
import "../../__vendor__/IERC20.sol";

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
     * @dev returns the confirmation that this is a project
     */
    function isProject() public pure returns (bool) { return true; }

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

    /**
     * @dev set {_descision} of {_user} from {_group} with {_voteWeight}
     */
    function setVote(
        address _group,
        address _user,
        BallotType.BallotResult _descision
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
        IERC20 group = IERC20(_group);
        uint256 voteWeight = group.balanceOf(_user);
        ballots.list[votingId].setVote(_group, _user, _descision, voteWeight);
        emit UserVote(_group, _user, _descision);
        return true;
    }


    /**
     * @dev get userVote
     */
    function getUserVote(
        uint votingId,
        address _group,
        address _user
    ) 
        public
        view
        returns (BallotType.BallotResult descision)
    {

        return ballots.list[votingId].votes[_group][_user];
    }

    /**
     * @dev get user vote weight
     */
    function getUserVoteWeight(
        uint votingId,
        address _group,
        address _user
    ) 
        public
        view
        returns (uint256 weight)
    {

        return ballots.list[votingId].votesWeight[_group][_user];
    }


    /**
     * @dev returns confirming that this user is voted
     * @return confirm
     */
     function isUserVoted (
         address _group,
         address _user
     )
        public
        view
        returns(bool confirm)
     {
        uint votingId = ballots.list.length - 1;
        confirm = ballots.list[votingId].votes[_group][_user] != BallotType.BallotResult.NOT_ACCEPTED;
     }
}
