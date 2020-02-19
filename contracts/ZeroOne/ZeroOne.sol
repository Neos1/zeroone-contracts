pragma solidity 0.6.1;
pragma experimental ABIEncoderV2;

import "./IZeroOne.sol";
import "./Notifier/Notifier.sol";
import "../lib/Meta.sol";
import "./Ballots/Ballots.sol";



/**
 * @title ZeroOne
 * @dev main ZeroOne contract
 */
contract ZeroOne is Notifier, IZeroOne, Ballots {
    using Meta for bytes;

    event ZeroOneCall(
        MetaData _meta
    );

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
        uint questionId = ballots.list[votingId].questionId;

        MetaData memory meta = MetaData({
            ballotId: votingId,
            questionId: questionId,
            startBlock: ballots.list[votingId].startBlock,
            endBlock: block.number,
            result: Result.ACCEPTED
        });

        makeCall(
            questions.list[questionId].target, 
            questions.list[questionId].methodSelector, 
            ballots.list[votingId].votingData,
            meta
        );
        emit VotingEnded(votingId, descision);
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
        public
        onlySelf()
        returns(uint ballotId)
    {
        _group.call(abi.encodeWithSignature("setAdmin(address)", _user));
        emit ZeroOneCall(_metaData);
        return _metaData.ballotId;
    }
}
