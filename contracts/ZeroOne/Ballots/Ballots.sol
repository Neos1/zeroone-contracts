pragma solidity 0.6.1;
pragma experimental ABIEncoderV2;

import "./lib/Ballot.sol";
import "./lib/BallotList.sol";
import "../Questions/QuestionsWithGroups.sol";
import "../UserGroups/UserGroups.sol";
import "./IBallots.sol";
import "../../__vendor__/IERC20.sol";
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

    event VotingEnded(uint votingId, VM.Vote descision);

    event UserVote(address user, VM.Vote descision);

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
     * @param _descision descision of {_user}
     * @return success
     */
    function setVote(
        VM.Vote _descision
    ) 
        public
        returns (bool success)
    {
        uint votingId = ballots.list.length - 1;

        for (uint i = 0; i < 16; i++) {
            DescriptorVM.Group storage group = ballots.descriptors[votingId].groups[i];
            DescriptorVM.User storage user = ballots.descriptors[votingId].users[i];
            
            if (group.groupAddress != address(0)) {
                bool excluded = isUserExcluded(group.exclude, msg.sender);
                if (!excluded) {
                    bool userVoted = didUserVote(group.groupAddress, msg.sender);
                    if (!userVoted) {
                        ballots.list[votingId].setVote(group.groupAddress, msg.sender, _descision);
                        (uint positive, uint negative, uint totalSupply) = ballots.list[votingId].getGroupVotes(group.groupAddress);
                        ballots.descriptors[votingId].groups[i].positive = positive;
                        ballots.descriptors[votingId].groups[i].negative = negative;
                        ballots.descriptors[votingId].groups[i].totalSupply = totalSupply;
                    }
                }
            }

            if (user.groupAddress != address(0)) { 

                if((user.userAddress != address(0)) && (user.userAddress == msg.sender)) {
                    bool userVoted = didUserVote(user.groupAddress, user.userAddress);
                    if (!userVoted) {
                        ballots.list[votingId].setVote(user.groupAddress, user.userAddress, _descision);
                    } else {
                        user.vote = getUserVote(votingId, group.groupAddress, user.userAddress);
                    }
                } else if ( (user.admin == true)  && (IERC20(user.groupAddress).owner() == msg.sender) ) {
                    user.userAddress = msg.sender;
                    bool userVoted = didUserVote(user.groupAddress, msg.sender);
                    if (!userVoted) {
                        ballots.list[votingId].setVote(user.groupAddress, msg.sender, _descision);
                        user.vote = _descision;
                    } else {
                        user.vote = getUserVote(votingId, group.groupAddress, msg.sender);
                    }
                }
            }
        }

        emit UserVote(msg.sender, _descision);
        return true;
    }

    /**
     * @dev updates vote of {_user} from {_group} with {_newVoteWeight}
     * @param _group address of group
     * @param _user address of user
     * @param _newVoteWeight new tokens amount of {_user}
     */
    function updateUserVote(
        address _group,
        address _user,
        uint256 _newVoteWeight
    ) 
        public
        returns (bool success)
    {
        uint votingId = ballots.list.length - 1;

        for (uint i = 0; i < 16; i++) {
            DescriptorVM.Group storage group = ballots.descriptors[votingId].groups[i];
            DescriptorVM.User storage user = ballots.descriptors[votingId].users[i];
            if ((group.groupAddress != address(0) && (group.groupAddress == _group))) {
                bool excluded = isUserExcluded(group.exclude, _user);
                if (!excluded) {
                    bool userVoted = didUserVote(group.groupAddress, msg.sender);
                    if (userVoted) {   
                        ballots.list[votingId].updateUserVote(_group, _user, _newVoteWeight);
                        (uint256 positive, uint256 negative, uint256 totalSupply) = ballots.list[votingId].getGroupVotes(group.groupAddress);
                        group.positive = positive;
                        group.negative = negative;
                        group.totalSupply = totalSupply;
                    }
                }
            }

            if ((user.groupAddress != address(0)) && (user.groupAddress == _group)) {
                if((user.userAddress != address(0)) && (user.userAddress == msg.sender)) {
                    bool userVoted = didUserVote(user.groupAddress, _user);
                    if (userVoted) {
                        ballots.list[votingId].updateUserVote(_group, _user, _newVoteWeight);
                        if (_newVoteWeight == 0) {
                            user.vote = VM.Vote.UNDEFINED;
                        }
                    }
                } else if ( (user.admin == true)  && (IERC20(user.groupAddress).owner() == msg.sender) ) {
                    user.userAddress = msg.sender;
                    bool userVoted = didUserVote(user.groupAddress, msg.sender);
                    if (userVoted) {
                        if (_newVoteWeight == 0) {
                            user.vote = VM.Vote.UNDEFINED;
                        }
                    }
                }
            }
        }
        emit UpdatedUserVote(_group, _user);
        return true;
    }   

    /**
     * @dev gets votes from voting with {_votingId} for {_group}
     * returns positive votes, negative votes, totalSupply of {_group}
     * @param _votingId id of voting
     * @param _group address of group
     * @return positive
     * @return negative
     * @return totalSupply
     */
    function getGroupVotes(
        uint _votingId,
        address _group
    )
      public
      view
      returns (
          uint256 positive,
          uint256 negative,
          uint256 totalSupply
      )
    {
        (positive, negative, totalSupply) = ballots.list[_votingId].getGroupVotes(_group);
    }

    /**
     * @dev checks, if {_user} address contains in {_exclude} list
     * @param _exclude list of users, which excluded from voting
     * @param _user user, which votes
     */
    function isUserExcluded(
        address[] memory _exclude,
        address _user
    )
        internal
        pure
        returns (bool excluded)
    {
        for (uint i = 0; i < _exclude.length; i++) {
            if (_exclude[i] == _user) {
                excluded = true;
                break;
            }
        }
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
        returns (VM.Vote descision)
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
        confirm = ballots.list[votingId].votes[_group][_user] != VM.Vote.UNDEFINED;
    }

    /**
     * @dev closes the voting by executing descriptors for result calculating
     * and setting BallotStatus.CLOSED
     * @return votingId
     * @return questionId
     * @return result
     */
    function closeVoting()
        public
        returns (
            uint votingId,
            uint questionId,
            VM.Vote result
        )
    {
        votingId = ballots.list.length - 1;
        questionId = ballots.list[votingId].questionId;

        require(ballots.list[votingId].endTime < block.timestamp, "Time is not over yet");
        bytes storage formula = questions.list[questionId].formula;
        address owners = groups.list[0].groupAddress;
        ballots.descriptors[votingId].executeResult(formula, owners);
        ballots.list[votingId].close();

        return (
            votingId, 
            questionId,
            ballots.descriptors[votingId].result
        );
    }

    /**
     * @dev gets voting result by {_votingId}
     * @param _votingId id of voting
     * @return result
     */
    function getVotingResult (
        uint _votingId
    )
        public
        view
        returns (VM.Vote result)
    {
        result = ballots.descriptors[_votingId].result;
    }
}
