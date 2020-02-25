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
    function setVote(address tokenAddr, address user, BallotResult descision) public returns (BallotResult) {
        IERC20 token = IERC20(tokenAddr);
        uint256 tokenBalance = token.balanceOf(user);
        require(token.transferFrom(user, address(this), tokenBalance));
        ballot.votes[tokenAddr][user] = descision;
        ballot.votesWeight[tokenAddr][user] = tokenBalance;
    }

    function updateUserVote(address tokenAddr, address user, uint256 newVoteWeight) public override returns(bool){
        uint256 oldVoteWeight = ballot.votesWeight[tokenAddr][user];
        uint index = uint(ballot.votes[tokenAddr][user]);
        uint256 oldDescisionWeight = ballot.descisionWeights[tokenAddr][index];

        if (ballot.status == BallotStatus.ACTIVE) {
            ballot.votesWeight[tokenAddr][user] = newVoteWeight;
            ballot.descisionWeights[tokenAddr][index] = oldDescisionWeight - oldVoteWeight + newVoteWeight;
            if (newVoteWeight == 0) {
                ballot.votes[tokenAddr][user] = BallotResult.NOT_ACCEPTED;
            }
        }
    }

    function getUserVote(address tokenAddr, address user) 
        public 
        view
        override
        returns(uint)
    {
        return uint(ballot.votes[tokenAddr][user]);
    }

    function getUserVoteWeight(address tokenAddr, address user) 
        public 
        view
        override
        returns(uint256)
    {
       return ballot.votesWeight[tokenAddr][user];
    }

    function didUserVote(address tokenAddr, address user)
        public 
        override 
        returns(bool)
    {
        return ballot.votes[tokenAddr][user] != BallotResult.NOT_ACCEPTED;
    }

    function submitVoting()
        public
        override
    {
        require(block.timestamp > ballot.endTime, "Time is not over");
        ballot.status = BallotStatus.CLOSED;
    }

    function setGroupAdmin(
        address tokenAddr, 
        address newOwner
    )
        public
        override 
    {
        tokenAddr.call(abi.encodeWithSignature("transferOwnership(address)", newOwner));
    }

    function disableUserGroup(address tokenAddr) public {
        tokenAddr.call(abi.encodeWithSignature("removeFromProjects(address)", address(this)));

    }
}
