pragma solidity 0.6.1;
pragma experimental ABIEncoderV2;

import "./Questions/QuestionsWithGroups.sol";
import "./UserGroups/UserGroups.sol";
import "./Ballots/Ballots.sol";
import "./Notifier/Notifier.sol";
import "../lib/Meta.sol";
import "zeroone-voting-vm/contracts/ZeroOneVM.sol";
import "./IZeroOne.sol";


/**
 * @title ZeroOne
 * @dev main ZeroOne contract
 */
contract ZeroOne is Notifier, IZeroOne, Ballots, UserGroups, QuestionsWithGroups {
    using Meta for bytes;

    event ZeroOneCall(
        MetaData _meta
    );

    constructor(address owners) public {
        UserGroup.Group memory _group = UserGroup.Group({
            name: "Owners",
            groupAddress: owners,
            groupType: UserGroup.Type.ERC20
        });

        addUserGroup(_group);
    }

    /**
     * @notice for modified functions allows only self external call
     */
    modifier onlySelf {
        require(
            msg.sender == address(this),
            "Only self call is possible"
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
     * @dev creates new Ballot in list, emits {VotingStarted}
     * @param _votingPrimary primary info about voting
     * @return id of new voting
     */
    function startVoting(
        BallotList.BallotSimple memory _votingPrimary
    )
        public
        noActiveVotings
        questionExists(_votingPrimary.questionId)
        groupIsAllowed(
            _votingPrimary.questionId,
            _votingPrimary.starterGroupId
        )
        returns (uint id)
     {
        _votingPrimary.endTime = block.timestamp + questions.list[_votingPrimary.questionId].timeLimit;
        
        id = Ballots.addVoting(
            _votingPrimary,
            questions.list[_votingPrimary.questionId].formula,
            groups.list[0].groupAddress
        );
    }


    /**
     * @dev closes last voting in list
     * @return success
     */
    function submitVoting() 
        public
        returns (bool)
    {
        uint votingId = ballots.list.length - 1;
        uint questionId = ballots.list[votingId].questionId;

        bytes storage formula = questions.list[questionId].formula;
        address owners = groups.list[0].groupAddress;

        VM.Vote result = Ballots.closeVoting(votingId, formula, owners);
        QuestionType.Question memory question = Questions.getQuestion(questionId);

        MetaData memory meta = MetaData({
            ballotId: votingId,
            questionId: questionId,
            startBlock: ballots.list[votingId].startBlock,
            endBlock: block.number,
            result: result
        });

        makeCall(
            question.target, 
            question.methodSelector, 
            ballots.list[votingId].votingData,
            meta
        );

        return true;
    }

    /**
     * @dev finds group by given address
     * @param _groupAddress address of group
     * @return group
     */
    function findGroupByAddress(address _groupAddress)
        internal
        view
        returns (UserGroup.Group memory group)
    {
        uint length = getUserGroupsAmount();
        for (uint i = 0; i <= length; i++) {
            if (groups.list[i].groupAddress == _groupAddress) {
                group = groups.list[i];
                break;
            }
        }
        return group;
    }

    /**
     * @dev revokes tokens and updates vote 
     */
    function revoke() 
        public
        returns (bool)
    {
        uint votingId = ballots.list.length - 1;
        for (uint i = 0; i < 16; i++) {
            DescriptorVM.Group storage group = ballots.descriptors[votingId].groups[i];
            DescriptorVM.User storage user = ballots.descriptors[votingId].users[i];

            if (group.groupAddress != address(0)) {
                if(didUserVote(group.groupAddress, msg.sender)) {
                    UserGroup.Group memory userGroup = findGroupByAddress(group.groupAddress);
                    IERC20 token = IERC20(userGroup.groupAddress);

                    if (userGroup.groupType == UserGroup.Type.ERC20) {
                        uint tokenCount = getUserVoteWeight(votingId, userGroup.groupAddress, msg.sender);
                        token.transferFrom(address(this), msg.sender, tokenCount);
                        ballots.list[votingId].updateUserVote(userGroup.groupAddress, msg.sender, 0);
                    } else if (userGroup.groupType == UserGroup.Type.ERC20) {
                        token.revoke(address(this));
                    }
                }
            }
        }
        return true;
    }

    /**
     * @notice makes call to contract external method
     * with modified data (meta added)
     * @param _target contract address to make call to
     * @param _method method selector
     * @param _data data to provide with call
     * @param _metaData meta to update data
     * @return result
     */
    function makeCall(
        address _target,
        bytes4 _method,
        bytes memory _data,
        MetaData memory _metaData
    )
        internal
        returns (bool result)
    {
        return notify(
            _target,
            _method,
            _data.addMetaData(abi.encode(_metaData))
        );
    }


    /**
     * @dev wrapper for QuestionsWithGroups.addQuestionGroup method
     * @param _metaData IZeroOne.MetaData
     * @param _questionGroup QuestionGroup, which will be added
     */
    function addQuestionGroup(
        MetaData memory _metaData,
        GroupType.Group memory _questionGroup
    )
        public
        onlySelf()
        returns (uint ballotId)
    {
        QuestionsWithGroups.addQuestionGroup(_questionGroup);
        emit ZeroOneCall(_metaData);
        return _metaData.ballotId;
    }

    /**
     * @dev wrapper for Questions.addQuestion method
     * @param _metaData IZeroOne.MetaData
     * @param _question Question, which will be added
     */
    function addQuestion(
        MetaData memory _metaData,
        QuestionType.Question memory _question
    )
        public
        onlySelf()
        returns (uint ballotId)
    {
        Questions.addQuestion(_question);
        emit ZeroOneCall(_metaData);
        return _metaData.ballotId;
    }

    /**
     * @dev wrapper for UserGroups.addUserGroup method
     * @param _metaData IZeroOne.MetaData
     * @param _group UserGroup, which will be added
     */
    function addUserGroup(
        MetaData memory _metaData,
        UserGroup.Group memory _group
    )
        public
        onlySelf()
        returns (uint ballotId)
    {
        UserGroups.addUserGroup(_group);
        emit ZeroOneCall(_metaData);
        return _metaData.ballotId;
    }

    /**
     * @dev wrapper for setAdmin method
     * @param _metaData IZeroOne.MetaData
     * @param _group address of group, which admin will be changed
     * @param _user address of user, which will be new admin
     */
    function setGroupAdmin(
        MetaData memory _metaData,
        address _group,
        address _user
    )
        internal
        onlySelf()
        returns(uint ballotId)
    {
        _group.call(abi.encodeWithSignature("transferOwnership(address)", _user));
        emit ZeroOneCall(_metaData);
        return _metaData.ballotId;
    }

    function disableUserGroup(address tokenAddr) internal {
        tokenAddr.call(abi.encodeWithSignature("removeFromProjects(address)", address(this)));

    }
}
