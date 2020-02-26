pragma solidity 0.6.1;
pragma experimental ABIEncoderV2;

import "./lib/Ballot.sol";
import "./lib/BallotList.sol";
import "../Questions/QuestionsWithGroups.sol";
import "../UserGroups/UserGroups.sol";
import "./IBallots.sol";
import "zeroone-voting-vm/contracts/ZeroOneVM.sol";


/**
 * @title Ballots
 * @dev stores Ballots
 */
contract Ballots is QuestionsWithGroups, UserGroups {
    using BallotList for BallotList.List;
    using BallotType for BallotType.Ballot;
    using ZeroOneVM for ZeroOneVM.Ballot;

    BallotList.List ballots;


    event VotingStarted(uint votingId, uint questionId);

    event VotingEnded(uint votingId, BallotType.BallotResult descision);

    event UserVote(address group, address user, BallotType.BallotResult descision);

    event UpdatedUserVote(address group, address user);

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
     * @dev creates new Ballot in list, emits {VotingStarted}
     * @param _votingPrimary primary info about voting
     * @return id of new voting
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
        ballots.descriptors[id].executeDescriptors(
            questions.list[_votingPrimary.questionId].formula,
            groups.list[0].groupAddress
        );
        emit VotingStarted(id, _votingPrimary.questionId);
    }

    /**
     * @dev getting the voting by id
     * @param _id id of voting
     * @return startTime
     * @return endTime
     * @return starterGroupId
     * @return starterAddress
     * @return questionId
     * @return status
     * @return votingData
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
     * @dev set {_descision} of {_user} from {_group}
     * method fetching balance of {_user} in {_group} and writing vote in voting struct
     * @param _group address of group
     * @param _user address of user
     * @param _descision descision of {_user}
     * @return success
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

        for (uint i = 0; i < 16; i++) {
            if (ballots.descriptors[votingId].groups[i].groupAddress == _group) {
                
            }
        }

        emit UserVote(_group, _user, _descision);
        return true;
    }

    /**
     * @dev updates vote weight of {_user} from {_group} with {_newVoteWeight}
     * calls when admin transfer tokens between users in custom token contract 
     * @param _group address of group
     * @param _user address of user
     * @param _newVoteWeight new vote weight of {_user}
     * @return status
     */
    function updateUserVote(address _group, address _user, uint256 _newVoteWeight)
        public  
        returns(bool status)
    {
        uint votingId = ballots.list.length - 1;
        status = ballots.list[votingId].updateUserVote(_group, _user, _newVoteWeight);
        emit UpdatedUserVote(_group, _user);
    }

    /**
     * @dev returns descision of {_user} from {_group} in voting with {_votingId}
     * @param _votingId id of voting
     * @param _group address of group
     * @param _user address of user
     * @return descision
     */
    function getUserVote(
        uint _votingId,
        address _group,
        address _user
    ) 
        public
        view
        ballotExist(_votingId)
        returns (BallotType.BallotResult descision)
    {

        return ballots.list[_votingId].votes[_group][_user];
    }

    /**
     * @dev return vote weight of {_user} from {_group} in voting with {_votingId}
     * @param _votingId id of voting
     * @param _group address of group
     * @param _user address of user
     * @return weight
     */
    function getUserVoteWeight(
        uint _votingId,
        address _group,
        address _user
    ) 
        public
        view
        returns (uint256 weight)
    {
        return ballots.list[_votingId].votesWeight[_group][_user];
    }

    /**
     * @dev returns confirming that this {_user} from {_group} is voted
     * @param _group address of group
     * @param _user address of user
     * @return confirm
     */
     function didUserVote (
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
